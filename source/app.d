import std.stdio;

import gtk.MainWindow;
import gtk.Widget;
import gtk.Main;
import gtk.Box;
import gtk.Label;
import gtk.Button;
import gdk.Event;
import gdk.Keymap;
import mbox;

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
	MBox mbox;

	this(string[][] mbData) {
		super("mBox Test");
		addOnDestroy(delegate void(Widget w) { mainQuit(); });

		setDefaultSize(600, 400);
		keymap = Keymap.getDefault();
		addOnKeyPress(&onKeyPress);
		mbox = new MBox(mbData, true);

		addOnScroll(delegate bool(Event e, Widget w) {
			writeln("scroll event");
			return true;
		});

		mbox.addOnButtonPress(delegate bool(Event e, Widget w) {
			auto eb = e.button();

			if (e.isDoubleClick(eb)) {
				writeln("mbox double check: get row data");
			} else {
				writeln("mbox single check: get position");
			}
			return true;
		});

		add(new MainBox(mbData, mbox, this));
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
				mbox.cursorUp();
				break;
			case "Down":
				mbox.cursorDown();
				break;
			case "Escape":
				if (mbox.cursorIsActive()) {
					mbox.clearCursor();
				} else {
					mainQuit();
				}
				break;
			case "Return":
				writeln(mbox.activeData());
				break;
			case "Delete":
				mbox.deleteActiveRow();
				break;
			case "F12":
				writeln("F12");
				mbox.addRow(
					["2019/05/14", "Mi veloz router", "ñññ", "Acceso all router de casa"]);
				break;
			case "F11":
				mbox.reverseData();
				break;
			default:
				writeln("New: ", key);
				break;
		}

		return true;
	}
}

class MainBox : Box {
	this(string[][] mbData, MBox mbox, MainWin mwin) {
		super(Orientation.VERTICAL, 0);

		auto headText = new Label("Ejemplo");
		headText.setMarginTop(8);
		headText.setMarginBottom(8);
		add(headText);

		add(mbox);
		writeln(mbox.getRow(0));

		auto close = new Button("Close");
		packEnd(close, false, false, 0);

		close.addOnClicked(delegate void(Button b) { mwin.mainQuit(); });
	}
}
