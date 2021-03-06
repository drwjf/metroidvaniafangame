//
//  GameLevelScene3.m
//  Metroidvania
//
//  Created by nick vancise on 10/29/18.
//
#import "GameLevelScene3.h"
#import "door.h"
#import "sciserenemy.h"
#import "waver.h"
#import "SKTUtils.h"
#import "PlayerProjectile.h"
#import "nettoriboss.h"

@implementation GameLevelScene3{
    SKTextureAtlas*_lvl3assets;
}

-(instancetype)initWithSize:(CGSize)size{
    self = [super initWithSize:size];
    if (self!=nil) {
        [self.map removeFromParent];
        self.map=nil;
        
        self.backgroundColor = [SKColor blackColor];
        self.map = [JSTileMap mapNamed:@"level3.tmx"];
        [self addChild:self.map];
    
        self.walls=[self.map layerNamed:@"walls"];
        self.hazards=[self.map layerNamed:@"hazards"];
        self.mysteryboxes=[self.map layerNamed:@"mysteryboxes"];
        self.background=[self.map layerNamed:@"background"];
        self.foreground=[self.map layerNamed:@"foreground"];
        self.foreground.zPosition=17;
        
        _lvl3assets=[SKTextureAtlas atlasNamed:@"lvl3assets"];
        
        __weak GameLevelScene3*weakself=self;
        self.userInteractionEnabled=NO; //for use with player enter scene
        
        //audio setup (get rid of reference to previous audio manager)
        self.audiomanager=nil;
        
        //player initializiation stuff
        self.player = [[Player alloc] initWithImageNamed:@"samus_standf.png"];
        self.player.position = CGPointMake(150, 170);
        self.player.zPosition = 15;
        
        SKConstraint*plyrconst=[SKConstraint positionX:[SKRange rangeWithLowerLimit:0 upperLimit:(self.map.mapSize.width*self.map.tileSize.width)-33] Y:[SKRange rangeWithUpperLimit:(self.map.tileSize.height*self.map.mapSize.height)-22]];
        plyrconst.referenceNode=self.parent;
        self.player.constraints=@[plyrconst];
        
        [self.map addChild:self.player];
        [self.player runAction:self.player.enterfromportalAnimation completion:^{[weakself.player runAction:[SKAction setTexture:weakself.player.forewards resize:YES]];weakself.userInteractionEnabled=YES;}];//need to modify to turn player when entering map, rename entermap/have seperate for travelthruportal
        
        self.player.forwardtrack=YES;
        self.player.backwardtrack=NO;
        
        //camera initialization
        SKRange *xrange=[SKRange rangeWithLowerLimit:self.size.width/2 upperLimit:(self.map.mapSize.width*self.map.tileSize.width)-self.size.width/2];
        SKRange *yrange=[SKRange rangeWithLowerLimit:self.size.height/2 upperLimit:(self.map.mapSize.height*self.map.tileSize.height)-self.size.height/2];
        SKConstraint*edgeconstraint=[SKConstraint positionX:xrange Y:yrange];
        self.camera.constraints=@[[SKConstraint distance:[SKRange rangeWithLowerLimit:0 upperLimit:4] toNode:self.player],edgeconstraint];
        
        //mutable arrays here
        [self.bullets removeAllObjects];
        [self.enemies removeAllObjects];
        self.bullets=[[NSMutableArray alloc]init];
        self.enemies=[[NSMutableArray alloc]init];
        self.doors=[[NSMutableArray alloc]init];
        
        //scene items here
        SKSpriteNode*powerupstatue=[SKSpriteNode spriteNodeWithTexture:[_lvl3assets textureNamed:@"powerupstatuelvl3.png"]];
        powerupstatue.position=CGPointMake(17*self.map.tileSize.width, 5*self.map.tileSize.height);
        [powerupstatue setScale:0.7];
        powerupstatue.zPosition=0;
        [self.map addChild:powerupstatue];
        
        SKSpriteNode*powerupbubble=[SKSpriteNode spriteNodeWithTexture:[_lvl3assets textureNamed:@"powerup_bubble1.png"]];
        powerupbubble.position=CGPointMake(powerupstatue.position.x-11, powerupstatue.position.y+11);
        [powerupbubble setScale:0.8];
        powerupbubble.zPosition=0;
        [self.map addChild:powerupbubble];
        [powerupbubble runAction:[SKAction repeatActionForever:[SKAction sequence:@[[SKAction animateWithTextures:@[[_lvl3assets textureNamed:@"powerup_bubble1.png"],[_lvl3assets textureNamed:@"powerup_bubble2.png"],[_lvl3assets textureNamed:@"powerup_bubble3.png"],[_lvl3assets textureNamed:@"powerup_bubble4.png"],[_lvl3assets textureNamed:@"powerup_bubble5.png"],[_lvl3assets textureNamed:@"powerup_bubble6.png"]] timePerFrame:0.2 resize:NO restore:YES],[SKAction waitForDuration:1.7]]]]];
        
        //doors here
        door *door1=[[door alloc] initWithTextureAtlas:_lvl3assets hasMarker:NO andNames:@[@"door.png",@"door1.png",@"door2.png"]];
        door1.position=CGPointMake(39*self.map.tileSize.width, 7*self.map.tileSize.height);
        [self.map addChild:door1];
        [self.doors addObject:door1];
        
        door *door2=[[door alloc] initWithTextureAtlas:_lvl3assets hasMarker:YES andNames:@[@"bluedoor1.png",@"bluedoor2.png",@"bluedoor3.png",@"bluedoor4.png",@"bluedoor5.png",@"marker",@"bluedoormeniscus1.png",@"bluedoormeniscus2.png",@"bluedoormeniscus3.png",@"bluedoormeniscus4.png",@"doormeniscus5.png"]];
        door2.position=CGPointMake(81*self.map.tileSize.width, 6*self.map.tileSize.height);
        [self.map addChild:door2];
        [self.doors addObject:door2];
        
        door *door3=[[door alloc] initWithTextureAtlas:_lvl3assets hasMarker:NO andNames:@[@"door.png",@"door1.png",@"door2.png"]];
        door3.position=CGPointMake(128.5*self.map.tileSize.width, 6*self.map.tileSize.height);
        [self.map addChild:door3];
        [self.doors addObject:door3];
        
        door *door4=[[door alloc] initWithTextureAtlas:_lvl3assets hasMarker:NO andNames:@[@"door.png",@"door1.png",@"door2.png"]];
        door4.position=CGPointMake(144.5*self.map.tileSize.width, 19*self.map.tileSize.height);
        [self.map addChild:door4];
        [self.doors addObject:door4];
        
        door *door5=[[door alloc] initWithTextureAtlas:_lvl3assets hasMarker:YES andNames:@[@"bluedoor1.png",@"bluedoor2.png",@"bluedoor3.png",@"bluedoor4.png",@"bluedoor5.png",@"marker",@"bluedoormeniscus1.png",@"bluedoormeniscus2.png",@"bluedoormeniscus3.png",@"bluedoormeniscus4.png",@"doormeniscus5.png"]];
        door5.position=CGPointMake(178.5*self.map.tileSize.width, 5*self.map.tileSize.height);
        [self.map addChild:door5];
        [self.doors addObject:door5];
        
        //enemies here
        nettoriboss *nettori=[[nettoriboss alloc] initWithPosition:CGPointMake(176*self.map.tileSize.width-10, 5*self.map.tileSize.height-2)];
        [self.map addChild:nettori];
        [self.enemies addObject:nettori];
        
        //SKEmitterNode*nettoriproj=[SKEmitterNode nodeWithFileNamed:@"nettori_projectile.sks"];
        //nettoriproj.position=CGPointMake(nettori.position.x-100, nettori.position.y+50);
        //nettoriproj.particleRenderOrder=SKParticleRenderOrderDontCare;
        //[self.map addChild:nettoriproj];
    
    }
    return self;
}

-(void)didMoveToView:(SKView *)view{
    //setup sound
    self.audiomanager=[gameaudio alloc];
    [self.audiomanager runBkgrndMusicForlvl:3];
    
    //__weak GameLevelScene3*weakself=self;
    dispatch_async(dispatch_get_main_queue(), ^{//deal with certain ui on main thread only
        [self setupVolumeSlider];
    });
}

-(void)replaybuttonpush:(id)sender{
    [[self.view viewWithTag:666] removeFromSuperview];
    [self.view presentScene:[[GameLevelScene3 alloc] initWithSize:self.size]];
    [gameaudio pauseSound:self.audiomanager.bkgrndmusic];
}

-(void)handleBulletEnemyCollisions{ //switch this to ise id in fast enumeration so as to keep 1 enemy arr with multiple enemy types
    
    for(id enemycon in [self.enemies reverseObjectEnumerator]){
        
        if([enemycon isKindOfClass:[sciserenemy class]]){
            sciserenemy*enemyconcop=(sciserenemy*)enemycon;
            if(fabs(self.player.position.x-enemyconcop.position.x)<70){  //minimize comparisons
                //NSLog(@"in here");
                if(CGRectContainsPoint(self.player.collisionBoundingBox, CGPointAdd(enemyconcop.enemybullet1.position, enemyconcop.position))){
                    //NSLog(@"enemy hit player bullet#1");
                    [enemyconcop.enemybullet1 setHidden:YES];
                    [self enemyhitplayerdmgmsg:25];
                }
                else if(CGRectContainsPoint(self.player.collisionBoundingBox,CGPointAdd(enemyconcop.enemybullet2.position, enemyconcop.position))){
                    //NSLog(@"enemy hit player buller#2");
                    [enemyconcop.enemybullet2 setHidden:YES];
                    [self enemyhitplayerdmgmsg:25];
                }
                if(self.player.meleeinaction && !self.player.meleedelay && CGRectIntersectsRect([self.player meleeBoundingBoxNormalized],enemyconcop.frame)){
                    //NSLog(@"meleehit");
                    [self.player runAction:self.player.meleedelayac];
                    [enemyconcop hitByMeleeWithArrayToRemoveFrom:self.enemies];
                }
            }
        }
        else if([enemycon isKindOfClass:[waver class]]){
            waver*enemyconcop=(waver*)enemycon;
            [enemyconcop updateWithDeltaTime:self.delta andPlayerpos:self.player.position];
            if(fabs(self.player.position.x-enemyconcop.position.x)<40 && fabs(self.player.position.y-enemyconcop.position.y)<60 && !enemyconcop.attacking){
                [enemyconcop attack];
            }
            if(CGRectIntersectsRect(self.player.frame,CGRectInset(enemyconcop.frame,2,0))){
                [self enemyhitplayerdmgmsg:15];
            }
            if(self.player.meleeinaction && !self.player.meleedelay && CGRectIntersectsRect([self.player meleeBoundingBoxNormalized],enemyconcop.frame)){
                //NSLog(@"meleehit");
                [self.player runAction:self.player.meleedelayac];
                [enemyconcop hitByMeleeWithArrayToRemoveFrom:self.enemies];
            }
        }
        else if([enemycon isKindOfClass:[nettoriboss class]]){
            [enemycon updateWithDeltaTime:self.delta];
        }
    }
    
    
    for(PlayerProjectile *currbullet in [self.bullets reverseObjectEnumerator]){
        if(currbullet.cleanup){//here to avoid another run through of arr
            //NSLog(@"removing from array");
            [self.bullets removeObject:currbullet];
            [currbullet removeFromParent];
            continue;//avoid comparing with removed bullet
        }
        
        for(id enemyl in self.enemies){
            //NSLog(@"bullet frame:%@",NSStringFromCGRect(currbullet.frame));
                enemyBase*enemylcop=(enemyBase*)enemyl;
                if(CGRectIntersectsRect(CGRectInset(enemylcop.frame,5,0), currbullet.frame) && !enemylcop.dead){
                    //NSLog(@"hit an enemy");
                    [enemylcop hitByBulletWithArrayToRemoveFrom:self.enemies];
                    [currbullet removeAllActions];
                    [currbullet removeFromParent];
                    [self.bullets removeObject:currbullet];
                    break; //if bullet hits enemy stop checking for same bullet
                }
        }
        
        for(door* door in _doors){//maybe handle doors along with enemies to disperse run through of this array
            if(fabs((self.player.position.x-door.position.x)<180) && CGRectIntersectsRect(door.frame, currbullet.frame) && !door.openAlready){
            [door opendoor];
            [currbullet removeAllActions];
            [currbullet removeFromParent];
            [self.bullets removeObject:currbullet];
            break; //if bullet hits enemy stop checking for same bullet
            }
        }
    }//for currbullet
    
    
    
}

-(void)checkAndResolveCollisionsForPlayer{
    
    NSInteger tileindecies[8]={7,1,3,5,0,2,6,8};
    self.player.onGround=NO;
    
    
    for(NSInteger i=0;i<8;i++){
        NSInteger tileindex=tileindecies[i];
        
        CGRect playerrect=[self.player collisionBoundingBox];
        CGPoint playercoordinate=[self.walls coordForPoint:self.player.desiredPosition];
        
        
        if(playercoordinate.y >= self.map.mapSize.height-1 ){ //sets gameover if you go below the bottom of the maps y max-1
            [self gameOver:0];
            return;
        }
        if(self.player.position.x>=(self.map.mapSize.width*self.map.tileSize.width)-220 && !self.repeating){
            [self.map addChild:self.travelportal];
            self.repeating=YES;
        }
        if(self.travelportal!=NULL && CGRectIntersectsRect(CGRectInset(playerrect,4,6),[self.travelportal collisionBoundingBox])){
            [self.player runAction:[SKAction moveTo:self.travelportal.position duration:1.5] completion:^{[self gameOver:1];}];
            return;
        }
        
        
        
        NSInteger tilecolumn=tileindex%3; //this is how array of coordinates around player is navigated
        NSInteger tilerows=tileindex/3;   //using a 3X3 grid
        
        CGPoint tilecoordinate=CGPointMake(playercoordinate.x+(tilecolumn-1), playercoordinate.y+(tilerows-1));
        
        NSInteger thetileGID=[self tileGIDAtTileCoord:tilecoordinate forLayer:self.walls];
        NSInteger hazardtilegid=[self tileGIDAtTileCoord:tilecoordinate forLayer:self.hazards];
        NSInteger mysteryboxgid=[self tileGIDAtTileCoord:tilecoordinate forLayer:self.mysteryboxes];
        
        
        if(thetileGID !=0 || mysteryboxgid!=0){
            CGRect tilerect=[self tileRectFromTileCoords:tilecoordinate];
            //NSLog(@"TILE GID: %ld Tile coordinate: %@ Tile rect: %@ Player Rect: %@",(long)thetileGID,NSStringFromCGPoint(tilecoordinate),NSStringFromCGRect(tilerect),NSStringFromCGRect(playerrect));
            //collision detection here
            
            if(CGRectIntersectsRect(playerrect, tilerect)){
                CGRect pl_tl_intersection=CGRectIntersection(playerrect, tilerect); //distance of intersection where player and tile overlap
                
                if(tileindex==7){
                    //tile below the sprite
                    self.player.desiredPosition=CGPointMake(self.player.desiredPosition.x, self.player.desiredPosition.y+pl_tl_intersection.size.height);
                    
                    self.player.playervelocity=CGPointMake(self.player.playervelocity.x, 0.0);
                    self.player.onGround=YES;
                }
                else if(tileindex==1){
                    //tile above the sprite
                    if(mysteryboxgid!=0){
                        //NSLog(@"hit a mysterybox!!");
                        [self.mysteryboxes removeTileAtCoord:tilecoordinate];
                        [self hitHealthBox]; //adjusts player healthlabel/healthbar
                    }
                    else{
                        self.player.desiredPosition=CGPointMake(self.player.desiredPosition.x, self.player.desiredPosition.y-pl_tl_intersection.size.height);
                        self.player.playervelocity=CGPointMake(self.player.playervelocity.x, 0.0);
                    }
                }
                else if(tileindex==3){
                    //tile back left of sprite
                    self.player.desiredPosition=CGPointMake(self.player.desiredPosition.x+pl_tl_intersection.size.width, self.player.desiredPosition.y);
                }
                else if(tileindex==5){
                    //tile front right of sprite
                    self.player.desiredPosition=CGPointMake(self.player.desiredPosition.x-pl_tl_intersection.size.width, self.player.desiredPosition.y);
                }
                else{
                    if(pl_tl_intersection.size.width>pl_tl_intersection.size.height){
                        //this is for resolving collision up or down due to ^
                        float intersectionheight;
                        if(thetileGID!=0){
                            self.player.playervelocity=CGPointMake(self.player.playervelocity.x, 0.0);
                        }
                        
                        if(tileindex>4){
                            intersectionheight=pl_tl_intersection.size.height;
                            self.player.onGround=YES;
                        }
                        else
                            intersectionheight=-pl_tl_intersection.size.height;
                        
                        self.player.desiredPosition=CGPointMake(self.player.desiredPosition.x, self.player.desiredPosition.y+intersectionheight);
                    }
                    else{
                        //this is for resolving collisions left or right due to ^
                        float intersectionheight;
                        
                        if(tileindex==0 || tileindex==6)
                            intersectionheight=pl_tl_intersection.size.width;
                        else
                            intersectionheight=-pl_tl_intersection.size.width;
                        
                        self.player.desiredPosition=CGPointMake(self.player.desiredPosition.x+intersectionheight, self.player.desiredPosition.y);
                    }
                    
                }
            }
        }//if thetilegid bracket
        
        if(hazardtilegid!=0){//for hazard layer
            CGRect hazardtilerect=[self tileRectFromTileCoords:tilecoordinate];
            if(CGRectIntersectsRect(CGRectInset(playerrect, 1, 0), hazardtilerect)){
                [self damageRecievedMsg];
                if(self.player.health<=0){
                    [self gameOver:0];
                }
            }//if rects intersect
        }//if hazard tile
        
        if(tileindex==3 || tileindex==5 || tileindex==1 || tileindex==7){
        for(door*tmpdoor in self.doors){
            [tmpdoor handleCollisionsWithPlayer:self.player];
        }
        }
        
    }//for loop bracket
    self.player.position=self.player.desiredPosition;
}//fnc bracket




/*- (void)dealloc {
    NSLog(@"LVL3 SCENE DEALLOCATED");
}*/

@end
