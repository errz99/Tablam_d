import std.stdio;
import std.typecons;
import std.conv;

import gtk.Widget;
import gtk.Box;
import gtk.Label;
import gtk.EventBox;
import gtk.Button;

class MBox : Box {
	private:
	Label[][] _labels;
	string[][] _data;
	string[][] _datax;
	int _position;
	int _outPosition = -1;
	int _lastPosition = -1;
	string[2] headMarkup;
	string[2] dataMarkup;
	string[2] cursorMarkup;

	public:
	this(string[][] data, bool hasHead) {
		if (hasHead == true) {
			_outPosition++;
		}
		_position = _outPosition;
		_lastPosition = _outPosition;

		string hma = "<span><tt><b>";
		string hmb = "</b></tt></span>";
		string dma = "<span background=\"white\"><tt>";
		string dmb = "</tt></span>";
		string cma = "<span foreground=\"white\" background=\"#6666dd\"><tt>";
		string cmb = "</tt></span>";

		headMarkup = [hma, hmb];
		dataMarkup = [dma, dmb];
		cursorMarkup = [cma, cmb];

		_data = data;
		_datax = createDataX(data);

		super(Orientation.VERTICAL, 4);
		setHalign(Align.CENTER);

		foreach (d; _datax) {
			auto row = new Box(Orientation.HORIZONTAL, 4);
			add(row);
			Label[] rowLabels;

			foreach (elemx; d) {
				auto ebox = new EventBox;
				row.add(ebox);
				auto label = new Label(elemx);
				label.setMarkup(dataMarkup[0] ~ elemx ~ dataMarkup[1]);
				ebox.add(label);
				rowLabels ~= label;
			}
			_labels ~= rowLabels;
		}

		if (hasHead == true && _labels.length > 0) {
			for (int i = 0; i < _labels[0].length; i++) {
				_labels[0][i].setMarkup(headMarkup[0] ~ _datax[0][i] ~ headMarkup[1]);
			}
		}
	}

	string[] getRow(int n) {
		return _data[n];
	}

//	void addRow(string[] row) {
//		writeln(row);
//	}

	void cursorDown() {
		_lastPosition = _position;
		_position++;
		if (_position == _data.length) {
			_position = _outPosition + 1;
		}
		updateCursor();
	}

	void cursorUp() {
		_lastPosition = _position;
		_position--;
		if (_position < _outPosition + 1) {
			_position = to!int(_data.length) - 1;
		}
		updateCursor();
	}

	void updateCursor() {
		if (_position > _outPosition) {
			for (int i = 0; i < _labels[0].length; i++) {
				_labels[_position][i].setMarkup(
					cursorMarkup[0] ~ _datax[_position][i] ~ cursorMarkup[1]);
			}
		}
		if (_lastPosition > _outPosition) {
			for (int i = 0; i < _labels[0].length; i++) {
				_labels[_lastPosition][i].setMarkup(
					dataMarkup[0] ~ _datax[_lastPosition][i] ~ dataMarkup[1]);
			}
		}
	}
	
	bool cursorIsActive() {
		if (_position > _outPosition) {
			return true;
		} else {
			return false;
		}
	}
	
	void cleanCursor() {
		if (_position > _outPosition) {
			for (int i = 0; i < _labels[0].length; i++) {
				_labels[_position][i].setMarkup(
					dataMarkup[0] ~ _datax[_position][i] ~ dataMarkup[1]);
			}
			_position = _outPosition;			
		}
	}						
}

string[][] createDataX(string[][] data) {
	import std.array : replicate;
	import std.uni : byGrapheme;
	import std.range.primitives : walkLength;

	string[][] datax;
	if (data.length == 0) {
		return datax;
	}

	int separation = 1;
	auto sep = " ".replicate(separation);

	ulong[] max;
	max.length = data[0].length;

	for (int j = 0; j < max.length; j++) {
		for (int i = 0; i < data.length; i++) {
			auto elemgr = data[i][j].byGrapheme;
			if (elemgr.walkLength > max[j]) {
				max[j] = elemgr.walkLength;
			}
		}
	}

	for (int i = 0; i < data.length; i++) {
		string[] row;

		for (int j = 0; j < data[i].length; j++) {
			auto elemgr = data[i][j].byGrapheme;
			ulong grow = max[j] - elemgr.walkLength;
			string elemx = sep ~ data[i][j] ~ " ".replicate(grow) ~ sep;
			row ~= elemx;
		}
		datax ~= row;
	}

	return datax;
}
