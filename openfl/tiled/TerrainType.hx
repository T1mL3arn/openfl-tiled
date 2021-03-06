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

class TerrainType {

	public var name(default, null):String;
	public var tileId(default, null):Int;
	public var properties(default, null):Map<String, String>;

	public function new(name:String, tileId:Int, properties:Map<String, String>) {
		this.name = name;
		this.tileId = tileId;
		this.properties = properties;
	}
	
	public static function fromGenericXml(xml:Xml):TerrainType
	{
		var name:String = xml.get('name');
		var tileId:Int = Std.parseInt(xml.get("tile"));
		var properties:Map<String, String> = new Map<String, String>();
		
		for (child in xml) {
			if (Helper.isValidElement(child)) {
				if (child.nodeName == "properties") {
					for (property in child) {
						if (Helper.isValidElement(property)) {
							Helper.setProperty(property, properties);
						}
					}
				}
			}
		}
		
		return new TerrainType(name, tileId, properties);
	}
}