import std.stdio;
import std.typecons;
import std.conv;
import std.random;

import gtk.MainWindow;
import gtk.Widget;
import gtk.Main;
import gtk.Box;
import gtk.Label;
import gtk.Button;
import gdk.Event;
import gdk.Keymap;
import gtk.StyleContext;
import gtk.CssProvider;

import tablam;

const string hma = "<span foreground=\"black\" background=\"white\" size=\"medium\"><tt><b>";
const string hmb = "</b></tt></span>";
const string dma = "<span foreground=\"blue\" background=\"white\" size=\"medium\"><tt>";
const string dmb = "</tt></span>";
const string cma = "<span foreground=\"black\" background=\"yellow\" size=\"medium\"><tt>";
const string cmb = "</tt></span>";

void main(string[] args) {

	string[][] mbData = [
		["Date", "Name", "URL", "Info"],
		["20190904", "Vodafone", "www.vodafone.com", "Mi cuenta en la web de Vodafone"],
		["20191001", "micuenta", "gmail.com", "Cuenta de correo en gmail"],
		["20190522", "BNK", "www.banco.com", "Pues eso, el banco y tal"],
		["20181105", "García", "www.zaragoza.es", "Ejemplo con tilde, y alguna cosilla"]];

	MainWin mwin;

	Main.init(args);

	mwin = new MainWin(mbData);

	Main.run();

}

class MainWin : MainWindow {
	Keymap keymap;
	Tablam tab;
	auto rnd = Random(42);
	CSS css;

	this(string[][] mbData) {
		super("mBox Test");
		addOnDestroy(delegate void(Widget w) { mainQuit(); });

		setDefaultSize(600, 400);
		keymap = Keymap.getDefault();
		addOnKeyPress(&onKeyPress);

		css = new CSS(getStyleContext());

		auto aligns = ["rigth", "left", "center", "left"];
		tab = new Tablam(mbData, true, aligns);
		tab.setCursorMarkup(cma, cmb);

		addOnScroll(delegate bool(Event e, Widget w) {
			writeln("scroll event");
			return true;
		});

		tab.addOnButtonPress(delegate bool(Event e, Widget w) {
			auto eb = e.button();

			if (e.isDoubleClick(eb)) {
				writeln("tab double check: get row data");
				if (tab.activeData() != []) {
					writeln(tab.activeData());
				} else {
					writeln("no data active");
				}

			} else {
				//writeln("tab single check: get position");
			}
			return true;
		});

		add(new MainBox(mbData, tab, this));
		showAll();
	}

	void mainQuit() {
		Main.quit();
		writeln("Bye.");
	}

	bool onKeyPress(GdkEventKey* eventKey, Widget widget) {
		string key = keymap.keyvalName(eventKey.keyval);

		switch (key) {
			case "Up":
				tab.cursorUp();
				break;
			case "Down":
				tab.cursorDown();
				break;
			case "Escape":
				if (tab.cursorIsActive()) {
					tab.clearCursor();
				} else {
					mainQuit();
				}
				break;
			case "Return":
				if (tab.activeData() != []) {
					writeln(tab.activeData());
				} else {
					writeln("no data active");
				}
				break;
			case "Delete":
				tab.deleteActiveRow();
				break;
			case "Insert":
				tab.addRow(modify(["20190101", "Mi veloz router",
					"www.here.com", "Acceso all router de casa"]));
				break;
			case "F12":
				tab.reverseData();
				break;
			case "e":
				if (eventKey.state & ModifierType.CONTROL_MASK) {
					auto toEdit = tab.activeData();
					if ( toEdit != []) {
						auto edited = modify(toEdit);
						tab.editActiveRow(edited);
					}
				}
				break;
			default:
				writeln("New: ", key);
				break;
		}

		return true;
	}

	private string[] modify(string[] str) {
		auto r = uniform(0, 255, rnd);
		auto y = uniform(2000, 2020, rnd);
		auto m = uniform(1, 13, rnd);
		auto d = uniform(1, 29, rnd);
		auto date = to!string(y) ~ "/" ~ to!string(m) ~ "/" ~ to!string(d);
		auto url = "www." ~ to!string(r) ~ ".com";
		str[0] = date;
		str[2] = url;
		return str;
	}
}

class MainBox : Box {
	this(string[][] mbData, Tablam tab, MainWin mwin) {
		super(Orientation.VERTICAL, 0);

		auto headText = new Label("Ejemplo");
		headText.setMarkup("<span foreground=\"green\"><b>Ejemplo</b></span>");
		headText.setMarginTop(8);
		add(headText);

		add(tab);

		auto close = new Button("Close");
		close.setName("close");
		packEnd(close, false, false, 0);

		close.addOnClicked(delegate void(Button b) { mwin.mainQuit(); });
	}
}

class CSS {
	CssProvider provider;
	string cssData = "window { font-size: 16px; }";

	this(StyleContext styleContext)	{
		provider = new CssProvider();
		provider.loadFromData(cssData);
		styleContext.addProvider(provider, GTK_STYLE_PROVIDER_PRIORITY_APPLICATION);
	}
}
