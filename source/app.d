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

	this(string[][] mbData) {
		super("mBox Test");
		addOnDestroy(delegate void(Widget w) { mainQuit(); });

		setDefaultSize(600, 400);
		keymap = Keymap.getDefault();
		addOnKeyPress(&onKeyPress);

		add(new MainBox(mbData, this));
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
				writeln("Key Up");
				break;
			case "Down":
				writeln("Key Down");
				break;
			case "Escape":
				mainQuit();
				break;
			case "Return":
				writeln("Return");
				break;
			case "Delete":
				writeln("Delete");
				break;
			case "F12":
				writeln("F12");
				break;
			case "F11":
				writeln("F11");
				break;
			default:
				writeln("New: ", key);
				break;
		}

		return true;
	}
}

class MainBox : Box {
	this(string[][] mbData, MainWin mwin) {
		super(Orientation.VERTICAL, 0);

		auto headText = new Label("Ejemplo");
		headText.setMarginTop(8);
		headText.setMarginBottom(8);
		add(headText);

		auto mbox = new MBox(mbData, true);
		add(mbox);

		auto close = new Button("Close");
		packEnd(close, false, false, 0);

		close.addOnClicked(delegate void(Button b) { mwin.mainQuit(); });
	}
}
