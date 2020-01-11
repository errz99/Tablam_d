import std.stdio;
import gtk.Widget;
import gtk.Box;
import gtk.Label;
import gtk.EventBox;
import gtk.Button;

class MBox : Box {
	private:
	Label[][] _labels;

	public:
	this(string[][] data, bool hasHead) {
		string hma = "<span><tt><b>";
		string hmb = "</b></tt></span>";
		string dma = "<span background=\"white\"><tt>";
		string dmb = "</tt></span>";
		string cma = "<span foreground=\"white\" background=\"#6666dd\"><tt>";
		string cmb = "</tt></span>";

		string[2] headMarkup = [hma, hmb];
		string[2] dataMarkup = [dma, dmb];
		string[2] cursorMarkup = [cma, cmb];

		string[][] datax = createDataX(data);

		super(Orientation.VERTICAL, 4);
		setHalign(Align.CENTER);

		foreach (d; datax) {
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
				_labels[0][i].setMarkup(headMarkup[0] ~ datax[0][i] ~ headMarkup[1]);
			}
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
