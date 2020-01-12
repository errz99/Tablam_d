import std.stdio;
import std.typecons;
import std.conv;

import gtk.Widget;
import gtk.Box;
import gtk.Label;
import gtk.EventBox;
import gtk.Button;
import glib.ListG;

import std.array : replicate;
import std.uni : byGrapheme;
import std.range.primitives : walkLength;

class MBox : Box {
private:
	bool _hasHead;
	Box[] _rows;
	Label[][] _labels;
	string[][] _data;
	string[][] _datax;
	int _position;
	int _outPosition = -1;
	int _lastPosition = -1;
	string[2] headMarkup;
	string[2] dataMarkup;
	string[2] cursorMarkup;
	int hsep = 2;
	ulong[] max;
	int separation = 1;

public:
	this(string[][] data, bool hasHead) {
		_hasHead = hasHead;
		if (_hasHead == true) {
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
		createDatax();

		super(Orientation.VERTICAL, hsep);
		setHalign(Align.CENTER);
		setBorderWidth(8);

		foreach (d; _datax) {
			processRow(d);
		}

		if (_hasHead == true && _labels.length > 0) {
			for (int i = 0; i < _labels[0].length; i++) {
				_labels[0][i].setMarkup(headMarkup[0] ~ _datax[0][i] ~ headMarkup[1]);
			}
		}
	}

	string[] getRow(int n) {
		return _data[n];
	}

	void cursorDown() {
		_lastPosition = _position;
		_position++;
		if (_position == _data.length) {
			_position = _outPosition + 1;
		}
		updateCursor();

		writeln("down ", _position);
	}

	void cursorUp() {
		_lastPosition = _position;
		_position--;
		if (_position < _outPosition + 1) {
			_position = to!int(_data.length) - 1;
		}
		updateCursor();

		writeln("up   ", _position);
	}

	bool cursorIsActive() {
		if (_position > _outPosition) {
			return true;
		} else {
			return false;
		}
	}

	void clearCursor() {
		if (_position > _outPosition) {
			for (int i = 0; i < _labels[0].length; i++) {
				_labels[_position][i].setMarkup(
					dataMarkup[0] ~ _datax[_position][i] ~ dataMarkup[1]);
			}
			_position = _outPosition;
		}
	}

	string[] activeData() {
		auto pos = _position;
		if (_hasHead == true && _position == _outPosition) {
			pos = -1;
		}
		if (pos >= 0) {
			return _data[pos];
		} else {
			return [];
		}
	}

	void addRow(string[] rdata) {
		auto rdatax = dataxForRow(rdata);
		_datax ~= rdatax;
		_data ~= rdata;

		processRow(rdatax);
		showAll();
	}

	void deleteActiveRow() {
		if ((_hasHead && _position > 0) || (!_hasHead && _position >= 0)) {
			_data = _data[0.._position - 1] ~ _data[_position..$];
			_datax = _datax[0.._position - 1] ~ _datax[_position..$];
			_labels = _labels[0.._position - 1] ~ _labels[_position..$];

			_rows[_position].destroy();
			_rows = _rows[0.._position - 1] ~ _rows[_position..$];

			_position = _outPosition;
			_lastPosition = _outPosition;

			writeln("\n", _data);
			writeln("\n", _data.length, _datax.length, _labels.length, _rows.length, _position);
		}
	}

	private void processRow(string[] rdata) {
		auto row = new Box(Orientation.HORIZONTAL, hsep);
		add(row);
		Label[] rowLabels;

		foreach (elemx; rdata) {
			auto ebox = new EventBox();
			row.add(ebox);
			auto label = new Label(elemx);
			label.setMarkup(dataMarkup[0] ~ elemx ~ dataMarkup[1]);
			ebox.add(label);
			rowLabels ~= label;
		}
		_rows ~= row;
		_labels ~= rowLabels;
	}

	private void updateCursor() {
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

	private string newElemx(string elem, ulong max) {
		auto sep = " ".replicate(separation);
		auto elemgr = elem.byGrapheme;
		ulong grow = max - elemgr.walkLength;

		return sep ~ elem ~ " ".replicate(grow) ~ sep;
	}

	private void updateMax(string[][] data) {
		for (int j = 0; j < max.length; j++) {
			for (int i = 0; i < data.length; i++) {
				auto elemgr = data[i][j].byGrapheme;
				if (elemgr.walkLength > max[j]) {
					max[j] = elemgr.walkLength;
				}
			}
		}
	}

	private void createDatax() {
		if (_data.length == 0) {
			return;
		}

		max.length = _data[0].length;
		updateMax(_data);

		for (int i = 0; i < _data.length; i++) {
			string[] row;

			for (int j = 0; j < _data[i].length; j++) {
				row ~= newElemx(_data[i][j], max[j]);
			}
			_datax ~= row;
		}
	}

	private string[] dataxForRow(string[] rdata) {
		auto sep = " ".replicate(separation);
		int[] changedMax;
		updateMax([rdata]);

		string[] row;
		for (int j = 0; j < rdata.length; j++) {
			row ~= newElemx(rdata[j], max[j]);
		}

		foreach (cm; changedMax) {
			writeln(cm);

			for (int j = 0; j < _data.length; j++) {
				auto elemgr = _data[j][cm].byGrapheme;
				ulong grow = max[cm] - elemgr.walkLength;
				string elemx = sep ~ _data[j][cm] ~ " ".replicate(grow) ~ sep;
				_datax[j][cm] = elemx;

				if (_hasHead && j == 0) {
					_labels[j][cm].setMarkup(headMarkup[0] ~ elemx ~ headMarkup[1]);
				} else if (j == _position) {
					_labels[j][cm].setMarkup(cursorMarkup[0] ~ elemx ~ cursorMarkup[1]);
				} else {
					_labels[j][cm].setMarkup(dataMarkup[0] ~ elemx ~ dataMarkup[1]);
				}
			}
		}

		return row;
	}
}
