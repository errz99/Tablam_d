import std.stdio;
import std.typecons;
import std.conv;
import std.algorithm;

import gtk.Widget;
import gtk.Box;
import gtk.Label;
import gtk.EventBox;
import gtk.Button;
import glib.ListG;
import gdk.Event;

import std.array : replicate;
import std.uni : byGrapheme;
import std.range.primitives : walkLength;

class MBox : Box {
private:
	bool _hasHead;
	string[][] _data;
	string[][] _datax;
	Label[][] labels;
	Box[] rows;
	int position;
	int outPosition = -1;
	int lastPosition = -1;
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
			outPosition++;
		}
		position = outPosition;
		lastPosition = outPosition;

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
		//max.length = _data[0].length;
		initialDatax();

		super(Orientation.VERTICAL, hsep);
		setHalign(Align.CENTER);
		setBorderWidth(8);

		foreach (idx, ref d; _datax) {
			processRow(d, cast(int)idx);
			//addRow(d);
		}

		if (_hasHead == true && labels.length > 0) {
			for (int i = 0; i < labels[0].length; i++) {
				labels[0][i].setMarkup(headMarkup[0] ~ _datax[0][i] ~ headMarkup[1]);
			}
		}
	}

	string[] getRow(int n) {
		return _data[n];
	}

	void cursorDown() {
		if ((_hasHead && _data.length > 1) || (!_hasHead && _data.length > 0)) {
			lastPosition = position;

			if (position < _data.length - 1) {
				position++;
			} else {
				position = outPosition + 1;
			}

			updateCursor();
		}
		writeln("down ", position);
	}

	void cursorUp() {
		lastPosition = position;
		position--;
		if (position < outPosition + 1) {
			position = to!int(_data.length) - 1;
		}
		if (position >= 0) {
			updateCursor();
		}
		writeln("up   ", position);
	}

	bool cursorIsActive() {
		if (position > outPosition) {
			return true;
		} else {
			return false;
		}
	}

	void clearCursor() {
		if (position > outPosition) {
			for (int i = 0; i < labels[0].length; i++) {
				labels[position][i].setMarkup(
					dataMarkup[0] ~ _datax[position][i] ~ dataMarkup[1]);
			}
			position = outPosition;
		}
	}

	string[] activeData() {
		auto pos = position;
		if (_hasHead == true && position == outPosition) {
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
		_datax ~= rdatax.dup;
		_data ~= rdata.dup;

		processRow(rdatax, cast(int)_data.length - 1);
		showAll();
	}

	void deleteActiveRow() {
		if ((_hasHead && position > 0) || (!_hasHead && position >= 0)) {
			children[position].destroy();

			_data = _data[0..position] ~ _data[position + 1..$];
			_datax = _datax[0..position] ~ _datax[position + 1..$];
			labels = labels[0..position] ~ labels[position + 1..$];
			rows = rows[0..position] ~ rows[position + 1..$];

			for (int i = 0; i < rows.length; i++) {
				rows[i].setName(to!string(i));
			}

			position = outPosition;
			lastPosition = outPosition;
		}
	}

	void reverseData() {
		if (_hasHead) {
			reverse(_data[1..$]);
			reverse(_datax[1..$]);

		} else {
			reverse(_data);
			reverse(_datax);
		}

		for (int i = 0; i < labels.length; i++) {
			for (int j = 0; j < labels[i].length; j++) {
				applyMarkup(i, j, _datax[i][j]);
			}
		}
	}

	private void processRow(ref string[] rdatax, int idx) {
		auto row = new Box(Orientation.HORIZONTAL, hsep);
		row.setName(to!string(idx));
		add(row);

		row.addOnButtonPress(delegate bool(Event e, Widget w) {
			auto eb = e.button();
			auto name = row.getName();

			if (to!int(name) > outPosition) {
				if (e.isDoubleClick(eb)) {
				} else if (position != to!int(name)) {
					lastPosition = position;
					position = to!int(name);
					updateCursor();
				}
			} else {
				//writeln("button pressed at header");
			}
			return false;
		});

		Label[] rowLabels;
		foreach (ref elemx; rdatax) {
			auto ebox = new EventBox();
			row.add(ebox);
			auto label = new Label(elemx);
			label.setMarkup(dataMarkup[0] ~ elemx ~ dataMarkup[1]);
			ebox.add(label);
			rowLabels ~= label;
		}
		rows ~= row;
		labels ~= rowLabels;
	}

	private void updateCursor() {
		if (position > outPosition) {
			for (int i = 0; i < labels[0].length; i++) {
				labels[position][i].setMarkup(
					cursorMarkup[0] ~ _datax[position][i] ~ cursorMarkup[1]);
			}
		}
		if (lastPosition > outPosition) {
			for (int i = 0; i < labels[0].length; i++) {
				labels[lastPosition][i].setMarkup(
					dataMarkup[0] ~ _datax[lastPosition][i] ~ dataMarkup[1]);
			}
		}
	}

	private string newElemx(ref string elem, ulong max) {
		auto sep = " ".replicate(separation);
		auto elemgr = elem.byGrapheme;
		ulong grow = max - elemgr.walkLength;
		return sep ~ elem ~ " ".replicate(grow) ~ sep;
	}

	private int[] updateMax(string[][] data) {
		int[] changedMax;

		for (int j = 0; j < max.length; j++) {
			for (int i = 0; i < data.length; i++) {
				auto elemgr = data[i][j].byGrapheme;
				if (elemgr.walkLength > max[j]) {
					max[j] = elemgr.walkLength;
					changedMax ~= j;
				}
			}
		}
		return changedMax;
	}

	private void initialDatax() {
		if (_data.length == 0) {
			return;
		}

		max.length = _data[0].length;
		updateMax(_data);
		int i;
		while (i < _data.length) {
			string[] row;

			for (int j = 0; j < _data[i].length; j++) {
				row ~= newElemx(_data[i][j], max[j]);
			}
			_datax ~= row;
			++i;
		}
	}

	private string[] dataxForRow(ref string[] rdata) {
		auto sep = " ".replicate(separation);
		int[] changedMax = updateMax([rdata]);

		string[] row;
		for (int j = 0; j < rdata.length; j++) {
			row ~= newElemx(rdata[j], max[j]);
		}

		foreach (cm; changedMax) {
			writeln(cm);
			int j;
			while (j < _data.length) {
				auto elemgr = _data[j][cm].byGrapheme;
				ulong grow = max[cm] - elemgr.walkLength;
				string elemx = sep ~ _data[j][cm] ~ " ".replicate(grow) ~ sep;
				_datax[j][cm] = elemx;
				applyMarkup(j, cm, elemx);
				++j;
			}
		}
		return row;
	}

	private void applyMarkup(int i, int j, ref string elemx) {
		if (_hasHead == true && i == 0) {
			labels[i][j].setMarkup(headMarkup[0] ~ elemx ~ headMarkup[1]);
		} else if (i == position) {
			labels[i][j].setMarkup(cursorMarkup[0] ~ elemx ~ cursorMarkup[1]);
		} else {
			labels[i][j].setMarkup(dataMarkup[0] ~ elemx ~ dataMarkup[1]);
		}
	}
}
