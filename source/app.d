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
		//["Date", "Name", "URL", "Info"],
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
		mbox = new MBox(mbData, false);

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
				writeln("Key Up");
				mbox.cursorUp();
				break;
			case "Down":
				writeln("Key Down");
				mbox.cursorDown();
				break;
			case "Escape":
				if (mbox.cursorIsActive()) {
					mbox.cleanCursor();
				} else {	
					mainQuit();
				}	
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
	this(string[][] mbData, MBox mbox, MainWin mwin) {
		super(Orientation.VERTICAL, 0);

		auto headText = new Label("Ejemplo");
		headText.setMarginTop(8);
		headText.setMarginBottom(8);
		add(headText);
		
		add(mbox);
		writeln(mbox.getRow(0));
		//mbox.addRow(["hola", "ke pasa", "aqui", "hoy"]);

		auto close = new Button("Close");
		packEnd(close, false, false, 0);

		close.addOnClicked(delegate void(Button b) { mwin.mainQuit(); });
	}
}
