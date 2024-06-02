// Beliefs

pos(boss,15,15).
checking_cells.
resource_needed(1).


// Plans

+my_pos(X,Y)
   :  checking_cells & not building_finished
   <- !check_for_resources.

// Se encontrou um recurso necessário que ainda não foi encontrado
// Então notifica os outros agentes, pega o recurso e continua a mineração
+!check_for_resources
   :  resource_needed(R) & found(R) & my_pos(X,Y) & not resource_found(R,X,Y)
   <- !stop_checking;
      !notify_resource_found(R,X,Y);
      !take(R,boss);
      !continue_mine.

// Se encontrou um recurso necessário que já foi encontrado
// Então pega o recurso e continua a mineração
+!check_for_resources
   :  resource_needed(R) & found(R) & my_pos(X,Y) & resource_found(R,X,Y)
   <- !stop_checking;
      !take(R,boss);
      !continue_mine.

// Se encontrou um recurso não desejado no momento, mas que não foi encontrado ainda
// Então notifica os outros agentes e move para a próxima célula
+!check_for_resources
   :  resource_needed(R1) & found(R2) & (R2 > R1) & my_pos(X,Y) & not resource_found(R2,X,Y)
   <- !notify_resource_found(R2,X,Y);
      move_to(next_cell).

// Se chegou na posição de um recurso necessário que já foi encontrado, foi esgotado, mas não foi marcado como esgotado
// Então notifica os outros agentes sobre o esgotamento e move para a próxima célula
+!check_for_resources
   :  resource_needed(R) & not found(R) & my_pos(X,Y) & resource_found(R,X,Y) & not resource_finished(R,X,Y)
   <- !notify_resource_finsihed(R,X,Y);
      move_to(next_cell).

// Se não encontrou nenhum recurso e não exite recurso necessário encontrado que não foi esgotado
//    ou encontrou um recurso que não será mais necessário
//    ou encontrou um recurso não necessário no momento, mas que já foi encotrado
// Então move para a próxima célula
+!check_for_resources
   :  not found(_) & not (resource_needed(R1) & resource_found(R1,X1,Y1) & not resource_finished(R1,X1,Y1))
      | found(R2) & resource_needed(R3) & (R2 < R3)
      | found(R2) & resource_needed(R3) & (R2 > R3) & my_pos(X2,Y2) & resource_found(R2,X2,Y2)
   <- move_to(next_cell).

// Se não encontrou nenhum recurso e conhece um recurso desejado que ainda não foi esgotado
// Então vai para a posição do recurso desejado
+!check_for_resources
   :  not found(_) & resource_needed(R) & resource_found(R,X,Y) & not resource_finished(R,X,Y)
   <- move_towards(X,Y).

+!notify_resource_found(R,X,Y) : true
   <- +resource_found(R,X,Y);
      .print("broadcast resource found R=", R, " X=", X, " Y=", Y);
      .broadcast(tell, resource_found(R,X,Y)).

+!notify_resource_finsihed(R,X,Y) : true
   <- +resource_finished(R,X,Y);
      .print("broadcast resource finished R=", R, " X=", X, " Y=", Y);
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

