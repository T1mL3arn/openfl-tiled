// Copyright (C) 2013 Christopher "Kasoki" Kaster
//
// This file is part of "openfl-tiled". <http://github.com/Kasoki/openfl-tiled>
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
package openfl.tiled;

import flash.geom.Point;

enum FigureType
{
	RECTANGLE;
	ELLIPSE;
	CIRCLE;
	POLYGON;
	POLYLINE;
	TILE;
}

class TiledObject {

	/** The objectgroup this object belongs to */
	public var parent(default, null):TiledObjectGroup;

	/** A identification number, which represents a part of the tileset. */
	public var gid(default, null):Int;

	/** The name of this object */
	public var name(default, null):String;

	/** The type of this object */
	public var type(default, null):String;
	
	/** The real type of figure from Tiled Editor */
	public var figureType(default, null):FigureType;

	/** The x coordinate of this object (in pixels!) */
	public var x(default, null):Float;

	/** The y coordinate of this object (in pixels!) */
	public var y(default, null):Float;

	/** The width of this object in pixels */
	public var width(default, null):Float;

	/** The width of this object in pixels */
	public var height(default, null):Float;

	/** Checks if this object has a polygons */
	public var hasPolygon(get_hasPolygon, null):Bool;

	/** Check if this object has a polylines */
	public var hasPolyline(get_hasPolyline, null):Bool;

	/** Contains all properties from this object */
	public var properties(default, null):Map<String, String>;
	
	/** Rotation of this object clockwise in degrees */
	public var rotation(default, null):Float;
	
	/** Points that represent polygon or polylone in local coordinate system */
	public var polyData(default, null):Array<Point>;

	private function new(parent:TiledObjectGroup, gid:Int, name:String, type:String, x:Float, y:Float,
			width:Float, height:Float, polyData:Array<Point>,
			properties:Map<String, String>, rotation:Float, figureType:FigureType) {
		this.parent = parent;
		this.gid = gid;
		this.name = name;
		this.type = type;
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.polyData = polyData;
		this.properties = properties;
		this.rotation = rotation;
		this.figureType = figureType;
	}

	/** Creates a new TiledObject-instance from the given Xml code. */
	public static function fromGenericXml(xml:Xml, parent:TiledObjectGroup):TiledObject {
		var gid:Int = xml.exists("gid") ? Helper.avoidNullInt(xml.get("gid")) : 0;
		var name:String = xml.get("name");
		var type:String = xml.get("type");
		var x:Float = Helper.avoidNullFloat(xml.get("x")); 					//Std.parseInt(xml.get("x"));
		var y:Float = Helper.avoidNullFloat(xml.get("y"));					//Std.parseInt(xml.get("y"));
		var width:Float = Helper.avoidNullFloat(xml.get("width"));			//Std.parseInt(xml.get("width"));
		var height:Float = Helper.avoidNullFloat(xml.get("height"));		//Std.parseInt(xml.get("height"));
		var rotation:Float = Helper.avoidNullFloat(xml.get("rotation"));	//Std.parseFloat(xml.get("rotation"));
		var properties:Map<String, String> = new Map<String, String>();
		var figureType:FigureType = null;
		var polyData:Array<Point> = null;
		
		if(gid > 0)
			figureType = FigureType.TILE;											// image tile
		else		
			figureType = FigureType.RECTANGLE;										// and just rectangle
		
		for (child in xml) 
		{
			if (Helper.isValidElement(child)) 
			{
				if (child.nodeName == "properties") {
					for (property in child) {
						if(Helper.isValidElement(property)) {
							properties.set(property.get("name"), property.get("value"));
						}
					}
				}
				
				if (child.nodeName == 'ellipse') {											// ellipse (or pseudo 'circle' object)
					//x += width / 2;
					//y += height / 2;
					
					if (width == height)
						figureType = FigureType.CIRCLE;
					else
						figureType = FigureType.ELLIPSE;
						
				} else if (child.nodeName == "polygon" || child.nodeName == "polyline") {	// polygon or polyline
					
					polyData = new Array<Point>();

					var pointsAsStringArray:Array<String> = child.get("points").split(" ");

					for(p in pointsAsStringArray) {
						var coords:Array<String> = p.split(",");
						polyData.push(new Point(Std.parseFloat(coords[0]), Std.parseFloat(coords[1])));
					}

					if(child.nodeName == "polygon") 
						figureType = FigureType.POLYGON;
					else if(child.nodeName == "polyline")
						figureType = FigureType.POLYLINE;
				}									
			}
			
		}
		
		return new TiledObject(parent, gid, name, type, x, y, width,
			height, polyData, properties, rotation, figureType);
	}

	private inline function get_hasPolygon():Bool {
		return figureType == FigureType.POLYGON;
	}

	private function get_hasPolyline():Bool {
		return figureType == FigureType.POLYLINE;
	}

}
