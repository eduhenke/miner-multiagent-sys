pos(boss,15,15).
checking_cells.
resource_needed(1).

+my_pos(X,Y) 
   :  checking_cells & not building_finished
   <- !check_for_resources.

// first found of a needed resource on current location
+!check_for_resources
   :  resource_needed(R) & not resource_at(R,X,Y) & found(R)
   <- !stop_checking;
      ?my_pos(X,Y);
      .print("first found of a needed resource(",R,") on current location(",X,",",Y,")");
   	.broadcast(tell,resource_at(R,X,Y));
      !take(R,boss);
      !continue_mine.

// first found of an unneeded resource on current location
+!check_for_resources
   :  not resource_at(R,X,Y) & found(R)
   <- ?my_pos(X,Y);
      .print("first found of an uneeded resource(",R,") on current location(",X,",",Y,")");
   	.broadcast(tell,resource_at(R,X,Y));
      move_to(next_cell).

// following findings of a needed resource on current location
+!check_for_resources
   :  resource_needed(R) & resource_at(R,X,Y) & found(R)
   <- !stop_checking;
      .print("following findings of a needed resource(",R,") on current location");
      !take(R,boss);
      !continue_mine.

// go to location where resource was found
+!check_for_resources
   :  resource_needed(R) & resource_at(R,X,Y) & not found(R)
   <- move_towards(X,Y).

// found out that the resource was emptied out, broadcast to everyone + keep moving
+!check_for_resources
   :  resource_needed(R) & not resource_at(R,X,Y) & not found(R)
   <- .broadcast(untell,resource_at(R,X,Y));
      .wait(100);
      move_to(next_cell).


+!stop_checking : true
   <- ?my_pos(X,Y);
      +pos(back,X,Y);
      -checking_cells.

+!take(R,B) : true
   <- 
      .wait(100);
   	mine(R);
      !go(B);
      drop(R).

+!continue_mine : true
   <- !go(back);
      -pos(back,X,Y);
      +checking_cells;
      !check_for_resources.

+!go(Position) 
   :  pos(Position,X,Y) & my_pos(X,Y)
   <- true.

+!go(Position) : true
   <- ?pos(Position,X,Y);
      .wait(100);
      move_towards(X,Y);
      !go(Position).

@psf[atomic]
+!search_for(NewResource) : resource_needed(OldResource)
   <- +resource_needed(NewResource);    
      -resource_needed(OldResource).

@pbf[atomic]
+building_finished : true
   <- .drop_all_desires;
      !go(boss).
