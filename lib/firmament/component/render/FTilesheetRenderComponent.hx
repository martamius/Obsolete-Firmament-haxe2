package firmament.component.render;


import firmament.component.base.FEntityComponent;
import firmament.component.render.FRenderComponentInterface;
import firmament.component.physics.FPhysicsComponentInterface;
import firmament.core.FCamera;
import firmament.core.FTilesheet;
import firmament.core.FTilesheetRenderHelper;

import nme.display.BitmapData;
import nme.geom.Matrix;
import nme.display.IBitmapDrawable;
import nme.geom.Point;
import nme.events.EventDispatcher;
import nme.geom.Rectangle;
import nme.Assets;
import nme.display.Tilesheet;
import firmament.core.FTilesheetManager;
import nme.display.Sprite;
/**
 * ...
 * @author jordan
 */
class FTilesheetRenderComponent extends FEntityComponent ,implements FRenderComponentInterface 
{
	var drawList:Array<Float>;
	var tilesheet:FTilesheet;
	var imageScale:Int;
	var tile:Int;
		
	public function new() {
		super();
		drawList = new Array<Float>();
		tile = 0;
		
	}

	override public function init(config:Dynamic){
		this._config = config;
		var image = config.image;
		var imageIsFileName = false;
		if(Std.is(config.tilesheetFile,String)){
			tilesheet = FTilesheetManager.getInstance().getTilesheetFromDifinitionFile(config.tilesheetFile);

		}
		else if(image !=null){
			if(Std.is(image,FTilesheet)){
				tilesheet = cast(image);
			}else{
				var bd:BitmapData;
				if(Std.is(image,String)){
					//trace("image: " + Std.string(image));
					bd = Assets.getBitmapData(cast(image,String));
					
				}
				else if(Std.is(image,BitmapData)){
					bd = cast(image,BitmapData);
				}
				else{
					throw("invalid tileSheetImage");
				}
				tilesheet = new FTilesheet(bd);
				if(imageIsFileName){
					tilesheet.setImageFileName(cast(image,String));
				}
				tilesheet.addTileRect(new Rectangle (0, 0, bd.width, bd.height),new Point(bd.width/2,bd.height/2));
			}
		}
		if(Std.is(config.tile,Int)){
			this.tile = config.tile;
		}

		imageScale = 100;
	}
	

	public function render(camera:FCamera):Void {
		var TILE_FIELDS = 6; // x+y+index+scale+rotation+alpha
		FTilesheetRenderHelper.getInstance().initCamera(camera);
		if (tilesheet == null) {
			trace('tilesheet is null');
			return;
		}
		
		var physicsComponent:FPhysicsComponentInterface = cast(this._entity.getComponent("physics"));
		var cameraPos = camera.getTopLeftPosition();
		//var matrix = new Matrix();
		var ratio = camera.getZoom() / imageScale;
		var pos = physicsComponent.getPosition();
		var nx = ((pos.x - cameraPos.x) * camera.getZoom());
		var ny = ((pos.y - cameraPos.y) * camera.getZoom());
		//matrix.scale(ratio,ratio);
		
		//trace(cameraPos.y);
		var index =0;
		drawList[index] = nx;
		drawList[index + 1] = ny;
		drawList[index + 2] = this.tile; // sprite index
		drawList[index + 3] = ratio;
		drawList[index + 4] = -physicsComponent.getAngle();
		drawList[index + 5] = 1;
		
		FTilesheetRenderHelper.getInstance().addToDrawList(tilesheet, drawList);
		/*tilesheet.drawTiles(camera.graphics, drawList, true, 
			Tilesheet.TILE_SCALE | Tilesheet.TILE_ROTATION | Tilesheet.TILE_ALPHA);*/
	}

	public function getBitmapData():BitmapData{
		var sprite:Sprite = new Sprite();
		var index =0;
		drawList[index] = 0;
		drawList[index + 1] = 0;
		drawList[index + 2] = this.tile; // sprite index
		drawList[index + 3] = 1;
		tilesheet.drawTiles(sprite.graphics, drawList, true, Tilesheet.TILE_ALPHA);
		return new BitmapData(0,0);
	}
	
	override public function getType():String {
		return "render";
	}
	
	
}