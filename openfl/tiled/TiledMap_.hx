package openfl.tiled;
import haxe.io.Path;
import lime.net.URLRequest;
import openfl.events.Event;
import openfl.net.URLLoader;

/**
 * ...
 * @author Timur Artiukhov
 */
class TiledMap_
{
	/** Builds map from embedded asset */
	public static function getFromAssets(path:String):TiledMap_
	{
		//path = Helper.joinPath(prefix, path);
		
		var xml = Assets.getText(Helper.joinPath("", path));
		var tiledMap = new TiledMap_(path);
		tiledMap.parseXML(xml);
		
		return tiledMap;
	}
	
	/** Asynchronously loads and builds map from embedded asset 
	 * @param	handler	Here you can get your map after loading.
	 */
	public static function loadFromAssets(path:String, handler:TiledMap_->Void):Void
	{	
		var tiledMap = new TiledMap_(path);
		function complete_(text:String)
		{
			tiledMap.parseXML(text);
			handler(tiledMap);
		}
		
		Assets.loadText(Helper.joinPath("", path), complete_);
	}
	
	/** Asynchronously loads map from external path 
	 *
	 * @return	URLLoader object, if you want to control loading process. 
	*/
	public static function loadExtern(path:String, handler:TiledMap_->Void):URLLoader
	{
		var request:URLRequest = new URLRequest(Helper.joinPath("", path));
		request.contentType = 'text/xml';
		
		var loader:URLLoader = new URLLoader();
		var tiledMap = new TiledMap_(path);
		
		var onComplete = function(e:Event):Void
		{
			var loader2:URLLoader = cast e.target;
			var xml:String = cast loader2.data;
			tiledMap.parseXML(xml);
			handler(tiledMap);
		}
		
		loader.addEventListener(Event.COMPLETE, onComplete);
		loader.load(request);
		
		return loader;
	}
	
	/** The path of the map file */
	public var path(default, null):String;

	/** The map width in tiles */
	public var widthInTiles(default, null):Int;

	/** The map height in tiles */
	public var heightInTiles(default, null):Int;

	/** The map width in pixels */
	public var totalWidth(get_totalWidth, null):Int;

	/** The map height in pixels */
	public var totalHeight(get_totalHeight, null):Int;

	/** TILED orientation: Orthogonal or Isometric */
	public var orientation(default, null):TiledMapOrientation;

	/** The tile width */
	public var tileWidth(default, null):Int;

	/** The tile height */
	public var tileHeight(default, null):Int;

	/** The background color of the map */
	public var backgroundColor(default, null):UInt;

	/** All tilesets the map is using */
	public var tilesets(default, null):Array<Tileset>;

	/** Contains all layers from this map */
	public var layers(default, null):Array<Layer>;

	/** All objectgroups */
	public var objectGroups(default, null):Array<TiledObjectGroup>;

	/** All image layers **/
	public var imageLayers(default, null):Array<ImageLayer>;

	/** All map properties */
	public var properties(default, null):Map<String, String>;

	public var backgroundColorSet(default, null):Bool = false;
	
	private function new(path:String) 
	{
		this.path = path;
	}
	
	private function parseXML(xml:String) {
		if (xml == null) return;
		
		var xml = Xml.parse(xml).firstElement();

		this.widthInTiles = Std.parseInt(xml.get("width"));
		this.heightInTiles = Std.parseInt(xml.get("height"));
		this.orientation = xml.get("orientation") == "orthogonal" ?
			TiledMapOrientation.Orthogonal : TiledMapOrientation.Isometric;
		this.tileWidth = Std.parseInt(xml.get("tilewidth"));
		this.tileHeight = Std.parseInt(xml.get("tileheight"));
		this.tilesets = new Array<Tileset>();
		this.layers = new Array<Layer>();
		this.objectGroups = new Array<TiledObjectGroup>();
		this.imageLayers = new Array<ImageLayer>();
		this.properties = new Map<String, String>();

		// get background color
		var backgroundColor:String = xml.get("backgroundcolor");

		// if the element isn't set choose white
		if(backgroundColor != null) {
			this.backgroundColorSet = true;

			// replace # with 0xff to match ARGB
			backgroundColor = StringTools.replace(backgroundColor, "#", "0xff");

			this.backgroundColor = Std.parseInt(backgroundColor);
		} else {
			this.backgroundColor = 0x00000000;
		}

		for (child in xml) {
			if(Helper.isValidElement(child)) {
				if (child.nodeName == "tileset") {
					var tileset:Tileset = null;

					if (child.get("source") != null) {
						var prefix = Path.directory(this.path) + "/";
						tileset = Tileset.fromGenericXml2(this, Helper.getText(child.get("source"), prefix));
					} else {
						tileset = Tileset.fromGenericXml2(this, child.toString());
					}

					tileset.setFirstGID(Std.parseInt(child.get("firstgid")));

					this.tilesets.push(tileset);
				} else if (child.nodeName == "properties") {
					for (property in child) {
						if (!Helper.isValidElement(property))
							continue;
						properties.set(property.get("name"), property.get("value"));
					}
				} else if (child.nodeName == "layer") {
					var layer:Layer = Layer.fromGenericXml2(child, this);

					this.layers.push(layer);
				} else if (child.nodeName == "objectgroup") {
					var objectGroup = TiledObjectGroup.fromGenericXml(child);

					this.objectGroups.push(objectGroup);
				} else if (child.nodeName == "imagelayer") {
					var imageLayer = ImageLayer.fromGenericXml2(this, child);

					this.imageLayers.push(imageLayer);
				}
			}
		}
	}
	
	/**
	 * Returns the Tileset which contains the given GID.
	 * @return The tileset which contains the given GID, or if it doesn't exist "null"
	 */
	public function getTilesetByGID(gid:Int):Tileset {
		var tileset:Tileset = null;

		for(t in this.tilesets) {
			if(gid >= t.firstGID) {
				tileset = t;
			}
		}

		return tileset;
	}

	/**
	 * Returns the total Width of the map
	 * @return Map width in pixels
	 */
	private function get_totalWidth():Int {
		return this.widthInTiles * this.tileWidth;
	}

	/**
	 * Returns the total Height of the map
	 * @return Map height in pixels
	 */
	private function get_totalHeight():Int {
		return this.heightInTiles * this.tileHeight;
	}

	/**
	 * Returns the layer with the given name.
	 * @param name The name of the layer
	 * @return The searched layer, null if there is no such layer.
	 */
	public function getLayerByName(name:String):Layer {
		for(layer in this.layers) {
			if(layer.name == name) {
				return layer;
			}
		}

		return null;
	}

	/**
	 * Returns the object group with the given name.
	 * @param name The name of the object group
	 * @return The searched object group, null if there is no such object group.
	 */
	public function getObjectGroupByName(name:String):TiledObjectGroup {
		for(objectGroup in this.objectGroups) {
			if(objectGroup.name == name) {
				return objectGroup;
			}
		}

		return null;
	}

	 /**
	  * Returns an object in a given object group
	  * @param name The name of the object
	  * @param inObjectGroup The object group which contains this object.
	  * @return An TiledObject, null if there is no such object.
	  */
	public function getObjectByName(name:String, inObjectGroup:TiledObjectGroup):TiledObject {
		for(object in inObjectGroup.objects) {
			if(object.name == name) {
				return object;
			}
		}

		return null;
	}
	
}