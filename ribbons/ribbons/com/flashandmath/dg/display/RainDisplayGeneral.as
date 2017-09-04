/*

Flash CS4 ActionScript 3 Tutorial by Dan Gries.

www.flashandmath.com.


*/


package com.flashandmath.dg.display {
	import com.flashandmath.dg.objects.*;
	import com.flashandmath.dg.dataStructures.*;
	import flash.geom.*;
	import flash.display.*;
	
	public class RainDisplayGeneral extends Sprite {
		
		public var RaindropClass:Class;
		
		public var gravity:Number;
		
		//The linked list onStageList is a list of all the raindrops currently
		//being animated.		
		public var onStageList:LinkedList;
		//The recycleBin stores raindrops that are no longer part of the animation, but 
		//which can be used again when new drops are needed.
		private var recycleBin:LinkedList;
		
		public var numOnStage:Number;
		public var numInRecycleBin:Number;
		public var displayWidth:Number;
		public var displayHeight:Number;
		
		//a vector defining wind velocity:
		public var wind:Point;
				
		public var defaultInitialVelocity:Point;
		public var defaultDropThickness:Number;
		public var windOnSplash:Number;
		public var noSplashes:Boolean;
		
		//the defaultDropColor is only used when drops are not randomly colored by
		//grayscale, gradient, or fully random color.
		public var defaultDropColor:uint;
		
		public var randomizeColor:Boolean;
		public var colorMethod:String;
		public var minGray:Number;
		public var maxGray:Number;
		public var _gradientColor1:uint;
		public var _gradientColor2:uint;
		public var dropLength:String;
		public var minSplashDrops:Number;
		public var maxSplashDrops:Number;
		public var defaultDropAlpha:Number;
		public var splashAlpha:Number;
		public var splashThickness:Number;
		public var splashMinVelX:Number;
		public var splashMaxVelX:Number;
		public var splashMinVelY:Number;
		public var splashMaxVelY:Number;
				
		//If drops go outside of the xRange of the viewable window, they can be
		//removed from the animation or kept in play.  If the wind is rapidly changing,
		//there is a possibility of the raindrops reemerging from the side, so
		//you may wish to keep the following variable set to false.
		public var removeDropsOutsideXRange:Boolean;
		
		public var removeDropsAboveCeiling:Boolean;
		public var removeDropsBelowFloor:Boolean;
		
		//These variance parameters allow for controlled random variation in
		//raindrop velocities.
		public var initialVelocityVarianceX:Number;
		public var initialVelocityVarianceY:Number;
		public var initialVelocityVariancePercent:Number;
		
		public var globalBreakawayTime:Number;
		public var breakawayTimeVariance:Number;
		
		public var randomAccel:Number;
		
		
		private var displayMask:Sprite;
		private var left:Number;
		private var right:Number;
		private var top:Number;
		private var bottom:Number;
		private var r1:Number;
		private var g1:Number;
		private var b1:Number;
		private var r2:Number;
		private var g2:Number;
		private var b2:Number;
		private var param:Number;
		private var r:Number;
		private var g:Number;
		private var b:Number;
		private var numSplashDrops:int;
		private var outsideTest:Boolean;		
		private var variance:Number;
		private var dropX:Number;
		
		public function RainDisplayGeneral(w = 400, h=300, useMask = true) {			
			displayWidth = w;
			displayHeight = h;
			onStageList = new LinkedList();
			recycleBin = new LinkedList();
			wind = new Point(0,0);
			defaultInitialVelocity = new Point(0,0);
			initialVelocityVarianceX = 0;
			initialVelocityVarianceY = 0;
			initialVelocityVariancePercent = 0;
			windOnSplash = 0.20;
					
			noSplashes = false;
			
			numOnStage = 0;
			numInRecycleBin = 0;
			
			if (useMask) {
				displayMask = new Sprite();
				displayMask.graphics.beginFill(0xFFFF00);
				displayMask.graphics.drawRect(0,0,w,h);
				displayMask.graphics.endFill();
				this.addChild(displayMask);
				this.mask = displayMask;
			}
			
			
			defaultDropColor = 0xFFFFFF;
			defaultDropThickness = 1;
			defaultDropAlpha = 1;
			gravity = 1;
			randomizeColor = true;
			colorMethod = "gray";
			minGray = 0;
			maxGray = 1;
			_gradientColor1 = 0x0000FF;
			_gradientColor2 = 0x00FFFF;
			dropLength = "short";
			
			splashAlpha = 0.6;
			splashThickness = 1;
			minSplashDrops = 4;
			maxSplashDrops = 8;
			splashMinVelX = -2.5;
			splashMaxVelX = 2.5;
			splashMinVelY = 1.5;
			splashMaxVelY = 4;
			
			removeDropsOutsideXRange = true;
			removeDropsAboveCeiling = false;
			removeDropsBelowFloor = true;
			
			globalBreakawayTime = 0;
			breakawayTimeVariance = 0;
			
			randomAccel = 0.03
			
		}
		
		public function get gradientColor1():uint {
			return _gradientColor1;
		}
		
		public function get gradientColor2():uint {
			return _gradientColor2;
		}
		
		public function set gradientColor1(input) {
			_gradientColor1 = uint(input);
			r1 = (_gradientColor1 >>16) & 0xFF;
			g1 = (_gradientColor1 >>8) & 0xFF;
			b1 = _gradientColor1 & 0xFF;
		}
		
		public function set gradientColor2(input) {
			_gradientColor2 = uint(input);
			r2 = (_gradientColor2 >>16) & 0xFF;
			g2 = (_gradientColor2 >>8) & 0xFF;
			b2 = _gradientColor2 & 0xFF;
		}
		
		//arguments are x, y, velx, vely, color, thickness, splashing
		public function addDrop(x0:Number, y0:Number, ...args):* {
			numOnStage++;
			var drop:*; 
			var dropColor:uint;
			var dropThickness:Number;
						
			//set color
			if (args.length > 2) {
				dropColor = args[2];
			}
			else if (randomizeColor) {
				if (colorMethod == "gray") {
					param = 255*(minGray + (maxGray-minGray)*Math.random());
					dropColor = param << 16 | param << 8 | param;
				}
				if (colorMethod == "gradient") {
					param = Math.random();
					r = int(r1 + param*(r2 - r1));
					g = int(g1 + param*(g2 - g1));
					b = int(b1 + param*(b2 - b1));
					dropColor = (r << 16) | (g << 8) | b;
				}
				if (colorMethod == "random") {
					dropColor = Math.random()*0xFFFFFF;
				}
			}
			else {
				dropColor = defaultDropColor;
			}			
			
			//set thickness
			if (args.length > 3) {
				dropThickness = args[3];
			}
			else {
				dropThickness = defaultDropThickness;
			}

			//check recycle bin for available drop:
			if (recycleBin.first != null) {
				numInRecycleBin--;
				drop = recycleBin.first;
				//remove from bin
				if (drop.next != null) {
					recycleBin.first = drop.next;
					drop.next.prev = null;
				}
				else {
					recycleBin.first = null;
				}
				drop.resetPosition(x0,y0);
				drop.visible = true;
			}
			//if the recycle bin is empty, create a new drop:
			else {
				drop = new RaindropClass(x0,y0);
				//add to display
				this.addChild(drop);
			}
			
			drop.thickness = dropThickness;
			drop.color = dropColor;
			
			//add to beginning of onStageList
			if (onStageList.first == null) {
				onStageList.first = drop;
				drop.prev = null; //may be unnecessary
				drop.next = null;
			}
			else {
				drop.next = onStageList.first;
				onStageList.first.prev = drop;  //may be unnecessary
				onStageList.first = drop;
				drop.prev = null; //may be unnecessary
			}
						
			//set initial velocity
			if (args.length < 2) {
				variance = (1+Math.random()*initialVelocityVariancePercent);
				drop.vel.x = defaultInitialVelocity.x*variance+Math.random()*initialVelocityVarianceX;
				drop.vel.y = defaultInitialVelocity.y*variance+Math.random()*initialVelocityVarianceY;
			}
			else {
				drop.vel.x = args[0];
				drop.vel.y = args[1];
			}
			
			//set alpha
			if (args.length > 4) {
				drop.alpha = args[4];
			}
			else {
				drop.alpha = defaultDropAlpha;
			}
			
			//set splashing/non-splashing type
			if (args.length > 5) {
				drop.splashing = args[5];
			}
			else {
				//turn off splashing if global noSplashes is set to true.
				//otherwise, make the drop a splashing type.
				drop.splashing = !noSplashes;
			}
			
			drop.atTerminalVelocity = false;
			
			drop.lifespan = 0;
			drop.breakawayTime = globalBreakawayTime*(1+breakawayTimeVariance*Math.random());
			drop.dead = false;
			
			drop.redraw();
			
			return drop;
		}
		
		public function update():void {
			var drop:* = onStageList.first; //note drop is untyped
			var nextDrop:*;
			while (drop != null) {
				//before lists are altered, record next drop
				nextDrop = drop.next;
				//move all drops. For each drop in onStageList:
				
				drop.lifespan++;
				
				//only update if drop's lifespan is beyond breakaway time.
				if (drop.lifespan > drop.breakawayTime) {
					
					//record lastLastPos
					drop.lastLastPos.x = drop.lastPos.x;
					drop.lastLastPos.y = drop.lastPos.y;
					
					//record lastPos
					drop.lastPos.x = drop.p1.x;
					drop.lastPos.y = drop.p1.y;
										
					//update vel
					if (!drop.atTerminalVelocity) {
						drop.vel.y += gravity - drop.airResistanceFactor*drop.vel.y+randomAccel*(2*Math.random()-1);
						drop.vel.x += -drop.airResistanceFactor*drop.vel.x+randomAccel*(2*Math.random()-1);
						//we also allow separately assigned accel property to affect velocity
						drop.vel.x += drop.accel.x;
						drop.vel.y += drop.accel.y;
					}
					
					//update position p1
					//As an aesthetic choice, we apply less wind to the splashes than
					//to the falling raindrops.
					if (drop.splashing) {
						drop.p1.x += drop.vel.x + wind.x;
						drop.p1.y += drop.vel.y + wind.y;
					}
					else {
						drop.p1.x += drop.vel.x + windOnSplash*wind.x;
						drop.p1.y += drop.vel.y + windOnSplash*wind.y;
					}
					
					//update p0				
					if (dropLength == "long") {
						//use for longer drops:
						drop.p0.x = drop.lastLastPos.x;
						drop.p0.y = drop.lastLastPos.y;
					}
					else if (dropLength == "short") {
						drop.p0.x = drop.lastPos.x;
						drop.p0.y = drop.lastPos.y;
					}
					else {
						//can add other kinds of dropLength types, for example, constant length.
					}
					
					outsideTest = false;
					
					//if drop offstage, add to recycle bin, make invisible
					if (removeDropsOutsideXRange) {
						outsideTest ||= (drop.p1.x + drop.width < 0)||(drop.p1.x - drop.width > displayWidth);
						//we don't need to create a splash for drops that disappear off the sides
						drop.splashing = false;
					}
					
					if (removeDropsBelowFloor) {
						outsideTest ||= (drop.p1.y - drop.height > displayHeight)
						drop.splashing = false;
					}
					
					if (removeDropsAboveCeiling) {
						outsideTest ||= (drop.p1.y + drop.height < 0)
						drop.splashing = false;
					}
					
					if (outsideTest||drop.dead) {
						recycleDrop(drop);
					}
					
					//call redrawing function
					drop.redraw();
				}
				
								
				drop = nextDrop;
			}
		}
		
		public function recycleDrop(drop:*):void {
			numOnStage--;
			numInRecycleBin++;
			
			if (drop.splashing) {
				//find accurate location for splash (interpolate backwards in time
				//to find where drop passed through ground level, assuming constant speed)
				dropX = drop.p0.x + (displayHeight-drop.p0.y)*(drop.p1.x-drop.p0.x)/(drop.p1.y-drop.p0.y);
				createSplash(dropX, drop.color);
			}
			
			drop.visible = false;
			
			//remove from onStageList
			if (onStageList.first == drop) {
				if (drop.next != null) {
					drop.next.prev = null;
					onStageList.first = drop.next;
				}
				else {
					onStageList.first = null;
				}
			}
			else {
				if (drop.next == null) {
					drop.prev.next = null;
				}
				else {
					drop.prev.next = drop.next;
					drop.next.prev = drop.prev;
				}
			}

			//add to recycle bin
			if (recycleBin.first == null) {
				recycleBin.first = drop;
				drop.prev = null; //may be unnecessary
				drop.next = null;
			}
			else {
				drop.next = recycleBin.first;
				recycleBin.first.prev = drop;  //may be unnecessary
				recycleBin.first = drop;
				drop.prev = null; //may be unnecessary
			}
			
			//reset accel
			drop.accel.x = 0;
			drop.accel.y = 0;
			
		}
		
		private function createSplash(x0:Number, c:uint):void {
			numSplashDrops = Math.ceil(minSplashDrops + Math.random()*(maxSplashDrops - minSplashDrops));
			for (var i:int = 0; i<=numSplashDrops-1; i++) {
				//arguments are x, y, velx, vely, color, thickness
				var randomSplashSize:Number = 0.75+0.75*Math.random();
				var velX:Number = randomSplashSize*(splashMinVelX+Math.random()*(splashMaxVelX-splashMinVelX));
				var velY:Number = -randomSplashSize*(splashMinVelY+Math.random()*(splashMaxVelY-splashMinVelY));
				var thisDrop = addDrop(x0, displayHeight, velX, velY, c, splashThickness, splashAlpha, false);
				thisDrop.breakawayTime = 0;
			}
		}
		
		
	}
}
				
		
			
