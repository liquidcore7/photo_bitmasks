import std.stdio;
import std.string;
import std.format;
// dmagick imports are broken, copy ~/.dub/packages/dmagick-0.2.1/dmagick to source directory
// depends on libmagickcore
import dmagick.Image;
import dmagick.ColorRGB;

void applyToPixel(ref ColorRGB col, ubyte delegate(ubyte) transform)
{
	col.redByte(transform(col.redByte)); 
	col.greenByte(transform(col.greenByte));
	col.blueByte(transform(col.blueByte));
}

void applyToImage(Image source, string prefix, string postfix, ubyte delegate(ubyte) transformFunc)
{
	auto cloned = source.clone;
	foreach(row; cloned.view) 
	{
		foreach(ref ColorRGB pixel; row)
			pixel.applyToPixel(transformFunc);
	}
	cloned.write(prefix ~ postfix);
}

void main(string[] args) 
{
    if (args.length != 2)
        throw new Exception("Input image should be passed as argument");

	string filename = args[1];
	auto main_image = new Image(filename);
	string prefix = args[1][0 .. lastIndexOf(args[1], '.')]; // remove extension

	//negation
	applyToImage(main_image, prefix, "_negated.png", delegate (ubyte b) => cast(ubyte)(~b));

	//bitmasks
	foreach(value; 5 .. 8) {
		ubyte mask = cast(ubyte) (1 << value);
		applyToImage(main_image, prefix, format("_and_mask_%d.png", mask), delegate (ubyte b) => cast(ubyte) (b & mask));
		applyToImage(main_image, prefix, format("_xor_mask_%d.png", mask), delegate (ubyte b) => cast(ubyte) (b ^ mask));
		applyToImage(main_image, prefix, format("_or_mask_%d.png", mask), delegate (ubyte b) => cast(ubyte) (b | mask));
	}
    
}
