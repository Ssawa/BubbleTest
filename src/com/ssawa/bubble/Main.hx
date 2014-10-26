package com.ssawa.bubble;

import flash.display.Sprite;
import flash.display.StageDisplayState;
import flash.Lib;
import flash.events.Event;
import flash.Vector.Vector;
import box2D.collision.*;
import box2D.dynamics.*;
import box2D.collision.shapes.*;
import box2D.common.math.*;
import box2D.dynamics.joints.*;

/**
 * ...
 * @author CJ DiMaggio
*/

class Main extends Sprite 
{	
	private var world:B2World;
	private var worldScale:Float = 30;
	private var sphereVector:Vector<B2Body>;
	private var blobX:Float;
	private var blobY:Float;
	private var particleNumber:Int = 20;
	private var particleDistance:Float = 50;
	
	public function new() {
		super ();
		init();
		world = new B2World(new B2Vec2(0, 10), true);
		debugDraw();
		floor();
		sphereVector = new Vector<B2Body>();
		sphereVector.push(sphere(blobX, blobY, 15));
		
		for (i in 0...particleNumber) {
			var angle:Float = (2 * Math.PI) / particleNumber * i;
			var posX:Float = blobX + particleDistance * Math.cos(angle);
			var posY:Float = blobY + particleDistance * Math.sin(angle);
			sphereVector.push(sphere(posX, posY, 2));
			var dJoint:B2DistanceJointDef = new B2DistanceJointDef();
			dJoint.bodyA = sphereVector[0];
			dJoint.bodyB = sphereVector[sphereVector.length - 1];
			dJoint.localAnchorA = new B2Vec2(0, 0);
			dJoint.localAnchorB = new B2Vec2(0, 0);
			dJoint.length = particleDistance / worldScale;
			dJoint.dampingRatio = 0.5;
			dJoint.frequencyHz = 5;
			var distanceJoint:B2DistanceJoint;
			distanceJoint = cast world.createJoint(dJoint);
			
			if (i > 0) {
					var distanceX:Float = posX / worldScale-sphereVector[sphereVector.length - 2].getPosition().x;
					var distanceY:Float = posY / worldScale-sphereVector[sphereVector.length - 2].getPosition().y;
					var distance:Float = Math.sqrt(distanceX * distanceX + distanceY * distanceY);
					dJoint.bodyA = sphereVector[sphereVector.length - 2];
					dJoint.bodyB = sphereVector[sphereVector.length - 1];
					dJoint.localAnchorA = new B2Vec2(0, 0);
					dJoint.localAnchorB = new B2Vec2(0, 0);
					dJoint.length = distance;
					distanceJoint = cast world.createJoint(dJoint);
			}
			
			if (i==particleNumber-1) {
				var distanceX:Float = posX / worldScale-sphereVector[1].getPosition().x;
				var distanceY:Float = posY / worldScale-sphereVector[1].getPosition().y;
				var distance:Float = Math.sqrt(distanceX * distanceX + distanceY * distanceY);
				dJoint.bodyA = sphereVector[1];
				dJoint.bodyB = sphereVector[sphereVector.length - 1];
				dJoint.localAnchorA = new B2Vec2(0, 0);
				dJoint.localAnchorB = new B2Vec2(0, 0);
				dJoint.length = distance;
				distanceJoint = cast world.createJoint(dJoint);
			}
		}
		addEventListener(Event.ENTER_FRAME, updateWorld);
	}
	
	private function init() {
		blobX = Lib.current.stage.stageWidth / 2;
		blobY = (Lib.current.stage.stageWidth / 2) - 100;
		//flash.Lib.current.stage.displayState = flash.display.StageDisplayState.FULL_SCREEN;
		
	}
	
	private function sphere(pX:Float, pY:Float, r:Float):B2Body {
		var bodyDef:B2BodyDef = new B2BodyDef();
		bodyDef.position.set(pX / worldScale, pY / worldScale);
		bodyDef.type = B2Body.b2_dynamicBody;
		var circleShape:B2CircleShape;
		circleShape = new B2CircleShape(r / worldScale);
		var fixtureDef:B2FixtureDef = new B2FixtureDef();
		fixtureDef.shape = circleShape;
		fixtureDef.density = 1;
		fixtureDef.restitution = 0.4;
		fixtureDef.friction = .05;
		var theSphere:B2Body = world.createBody(bodyDef);
		theSphere.createFixture(fixtureDef);
		return theSphere;
	}
	
	private function floor():Void {
		var bodyDef:B2BodyDef = new B2BodyDef();
		bodyDef.position.set((-360)/ worldScale, (Lib.current.stage.stageHeight - 15)/ worldScale);
		var polygonShape:B2PolygonShape = new B2PolygonShape();
		polygonShape.setAsBox(Lib.current.stage.stageWidth / worldScale, 15 / worldScale);
		var fixtureDef:B2FixtureDef = new B2FixtureDef();
		fixtureDef.shape = polygonShape;
		fixtureDef.restitution = 0.4;
		fixtureDef.friction = 0.5;
		var theFloor:B2Body = world.createBody(bodyDef);
		theFloor.createFixture(fixtureDef);
	}
	
	private function debugDraw():Void {
		var debugDraw:B2DebugDraw = new B2DebugDraw();
		var debugSprite:Sprite = new Sprite();
		addChild(debugSprite);
		debugDraw.setSprite(debugSprite);
		debugDraw.setDrawScale(worldScale);
		debugDraw.setFlags(B2DebugDraw.e_shapeBit | B2DebugDraw.e_jointBit);
		debugDraw.setFillAlpha(0.5);
		world.setDebugDraw(debugDraw);
	}
	
	private function updateWorld(e:Event):Void {
		world.step(1 / 60, 10, 10);
		world.clearForces();
		world.drawDebugData();
	}
}