pos(boss,15,15).
checking_cells.
resource_needed(1).

+my_pos(X,Y) 
   :  checking_cells & not building_finished
   <- !check_for_resources.

// first found of an unneeded resource on current location
+!check_for_resources
   : found(R) & not resource_needed(R)
   <- ?my_pos(X,Y);
      .print("first found of an uneeded resource(",R,") on current location(",X,",",Y,")");
      +resource_at(R,X,Y);
   	.broadcast(tell,resource_at(R,X,Y));
      move_to(next_cell).

// first found of a needed resource on current location
+!check_for_resources
   :  resource_needed(R) & not resource_at(R,X,Y) & found(R)
   <- !stop_checking;
      ?my_pos(X,Y);
      .print("first found of a needed resource(",R,") on current location(",X,",",Y,")");
      +resource_at(R,X,Y);
   	.broadcast(tell,resource_at(R,X,Y));
      !take(R,boss);
      !continue_mine.

// following findings of a needed resource on current location
+!check_for_resources
   :  resource_needed(R) & resource_at(R,X,Y) & found(R)
   <- !stop_checking;
      .print("following findings of a needed resource(",R,") on current location");
      !take(R,boss);
      !continue_mine.

// keep moving + found out that the resource was emptied out, broadcast to everyone
+!check_for_resources
   :  resource_needed(R) & resource_at(R,X,Y) & not found(R) & my_pos(X,Y)
   <- -resource_at(R,X,Y);
      .print("found emptied out resource(",R,") at location(",X,",",Y,")");
      .broadcast(untell,resource_at(R,X,Y));
      +checking_cells;
      !check_for_resources.

// first go to location where resource was found
+!check_for_resources
   :  resource_needed(R) & resource_at(R,X,Y) & not found(R) & not my_pos(X,Y)
   <- .print("helping to find resource(",R,") at location(",X,",",Y,")");
      ?my_pos(Xback,Yback);
      +pos(help_collect_back,Xback,Yback);
      .wait(100);
      move_towards(X,Y).

// default branch for moooove.
+!check_for_resources
   :  true
   <- .print("MOVIIING");
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
