pos(boss,15,15).
checking_cells.
resource_needed(1).

+my_pos(X,Y) 
   :  checking_cells & not building_finished
   <- !check_for_resources.

+!check_for_resources
   :  resource_needed(R) & resource_at(R,X,Y) & found(R)
   <- !stop_checking;
      !take(R,boss);
      !continue_mine.
   
+!check_for_resources
   :  resource_needed(R) & not resource_at(R,X,Y) & found(R)
   <- !stop_checking;
      ?my_pos(X,Y);
   	.broadcast(tell,resource_at(R,X,Y));
      !take(R,boss);
      !continue_mine.

+!check_for_resources
   :  resource_needed(R) & resource_at(R,X,Y) & not found(R)
   <- move_towards(X,Y).

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
