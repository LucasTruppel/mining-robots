// Beliefs

pos(boss,15,15).
checking_cells.
resource_needed(1).


// Plans

+my_pos(X,Y)
   :  checking_cells & not building_finished
   <- !check_for_resources.

+!check_for_resources
   :  resource_needed(R) & found(R) & my_pos(X,Y) & not resource_found(R,X,Y)
   <- !stop_checking;
      !notify_others(R,X,Y);
      !take(R,boss);
      !continue_mine.

+!check_for_resources
   :  resource_needed(R) & found(R) & my_pos(X,Y) & resource_found(R,X,Y)
   <- !stop_checking;
      !take(R,boss);
      !continue_mine.

+!check_for_resources
   :  resource_needed(R) & not found(R) & my_pos(X,Y) & resource_found(R,X,Y) & not resource_finished(R,X,Y)
   <- !notify_resource_finsihed(R,X,Y);
      move_to(next_cell).

+!check_for_resources
   :  resource_needed(R) & not found(R) & not (resource_found(R,X,Y) & not resource_finished(R,X,Y))
   <- move_to(next_cell).

+!check_for_resources
   :  resource_needed(R) & not found(R) & resource_found(R,X,Y) & not resource_finished(R,X,Y)
   <- move_towards(X,Y).

+!notify_others(R,X,Y) : true
   <- +resource_found(R,X,Y);
      .print("notifying others");
      .broadcast(tell, resource_found(R,X,Y)).

+!notify_resource_finsihed(R,X,Y) : true
   <- +resource_finished(R,X,Y);
      .print("notifying others");
      .broadcast(tell, resource_finished(R,X,Y)).

+!stop_checking : true
   <- ?my_pos(X,Y);
      +pos(back,X,Y);
      -checking_cells.

+!take(R,B) : true
   <- mine(R);
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

