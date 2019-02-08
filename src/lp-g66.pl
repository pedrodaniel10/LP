% ##############################################################################################################################%
% ################################################ Logica para Programacao #####################################################%
% ##############################################################################################################################%
% # Projeto - Labirintos					      							       #%
% # Pedro Lopes nr 83540 - Grupo 66.				       							       #%
% ##############################################################################################################################%
% ################################################# Resolucao do Projeto #######################################################%
% ##############################################################################################################################%
% #################################################### movs_possiveis ##########################################################%
% movs_possiveis/4, movs_possiveis(Lab1,Pos_atual,Movs,Poss) - afirma que Poss e' a lista com todos os movimentos possiveis     %
% por estando na posicao Pos_atual do labirinto Lab1, afirma que Poss nao contem um movimento para uma celula presente em Movs. %
% ##############################################################################################################################%
movs_possiveis(Lab1,Pos_atual,Movs,Poss):- (I,J)=Pos_atual,
					   enesimo(I, Lab1, Linha),
					   enesimo(J, Linha, Celula),
					   diferenca_conjunto([c,b,e,d], Celula, Direcoes_poss),
					   calcula_coord(Direcoes_poss, Pos_atual, Movs_poss),
					   verifica_ja_passou(Movs, Movs_poss, Poss).

% ###################################################### distancia #############################################################%
% distancia/3, distancia((L1, C1),(L2, C2),Dist) - afirma que Dist e a distancia entre o ponto (L1,C1) e o ponto (L2,C2).       %
% ##############################################################################################################################%
distancia((L1, C1),(L2, C2),Dist):- Dist is abs(L1-L2)+abs(C1-C2).

% ##################################################### ordena_poss ############################################################%
% ordena_poss/4, ordena_poss(Poss,Poss_ord,Pos_inicial,Pos_final) - afirma que Poss_ord sao as Poss ordenadas segundo dois cri- %
% terios em primeiro lugar, os movimentos conducentes 'a menor distancia a Pos_final, e, em caso de igualdade, os movimentos    %
% conducentes a uma maior distancia a Pos_inicial.										%
% ##############################################################################################################################%
ordena_poss([],[],_,_):-!.
ordena_poss([P|R],Poss_ord, (Xi,Yi), (Xf,Yf)):- (_,I,J)=P,
						distancia((I,J),(Xf,Yf), Dist_final),
						parte(R, (Xf,Yf), Dist_final, Menor, Igual, Maior),
						ordena_acordo_distancia([P|Igual], Res_igual, (Xi,Yi), decrescente),
						ordena_acordo_distancia(Menor, Res_menor, (Xf,Yf), crescente),
						ordena_acordo_distancia(Maior, Res_maior,(Xf,Yf), crescente),
						ordena_poss(Res_menor, Res_menor_ord, (Xi,Yi),(Xf,Yf)),
						ordena_poss(Res_maior, Res_maior_ord, (Xi,Yi),(Xf,Yf)),
						junta(Res_menor_ord, Res_igual, Res_intermedio),
						junta(Res_intermedio, Res_maior_ord, Poss_ord).

% ##################################################### resolve1 ###############################################################%
% resolve1/4, resolve1(Lab,Pos_inicial,Pos_final,Movs) - afirma que Movs sao os movimentos corretos para a resolucao do Lab 	%
% (que comeca em Pos_inicial e acaba em Pos_final). Os movimentos sao testados pela ordem [c, b, e, d].				%
% ##############################################################################################################################%
resolve1(Lab,(Xi,Yi),Pos_final,Movs):- resolve1(Lab, Pos_final, (Xi,Yi), [(i,Xi,Yi)], Movs).
resolve1(_,Pos_atual,Pos_atual,Aux,Aux):-!.
resolve1(Lab,(Xf,Yf),Pos_atual,Aux,Movs):- movs_possiveis(Lab, Pos_atual, Aux,Poss),
	                                   membro(Mov,Poss),
					   (_,I,J)=Mov,
					   Pos_atual2=(I,J),
					   junta(Aux, [Mov], Aux2),
					   resolve1(Lab, (Xf,Yf), Pos_atual2, Aux2, Movs),!.

% ##################################################### resolve2 ###############################################################%
% resolve2/4, resolve1(Lab,Pos_inicial,Pos_final,Movs) - afirma que Movs sao os movimentos corretos para a resolucao do Lab 	%
% (que comeca em Pos_inicial e acaba em Pos_final). A solucao Movs e' gerada escolhendo entre os varios movimentos possiveis,   %
% aquele que se aproximar mais da Pos_final. Se existirem varios movimentos conducentes a posicoes com a mesma distancia a 	%
% Pos_final, e' escolhido o que mais se distanciar da Pos_inicial. No caso de existirem varios movimentos conducentes a posi-	%
% coes com as mesmas distancias 'as posições inicial e final, e' seguida a ordem [c, b, e, d].					%
% ##############################################################################################################################%
resolve2(Lab,Pos_inicial,Pos_final,Movs):- (Xi,Yi)=Pos_inicial,
					   resolve2(Lab, Pos_inicial, Pos_final, Pos_inicial, [(i,Xi,Yi)], Movs).
resolve2(_,_,Pos_atual,Pos_atual,Aux,Aux):-!.
resolve2(Lab,(Xi,Yi),(Xf,Yf),Pos_atual,Aux,Movs):- movs_possiveis(Lab, Pos_atual, Aux, Poss),
						   ordena_poss(Poss,Poss_ord, (Xi,Yi), (Xf,Yf)),
						   membro(Mov,Poss_ord),
						   (_,I,J)=Mov,
					           Pos_atual2=(I,J),
					           junta(Aux, [Mov], Aux2),
					           resolve2(Lab, (Xi,Yi), (Xf,Yf), Pos_atual2, Aux2, Movs),!.

% ##############################################################################################################################%
% ################################################# Predicados Auxiliares ######################################################%
% ##############################################################################################################################%
% #################################################### calcula_coord ###########################################################%
% calcula_coord/3, calcula_coord(Direcoes, Posicao_atual, Movimentos) - afirma que Movimentos sao o conjunto de movimentos da	% 
% forma (<direcao>,<Ci>,<Cj>) onde as coordenadas (Ci,Cj) sao calculados a partir da Posicao_atual e a diracao na lista Dire-	%
% coes.																%
% ##############################################################################################################################%
calcula_coord(Direcoes, Posicao_atual, Movimentos):- calcula_coord(Direcoes, Posicao_atual, [], Movimentos).
calcula_coord([], _ ,Aux, Aux):-!.
calcula_coord([c|R], Posicao_atual, Aux, Movimentos):- !,(I,J)=Posicao_atual,
						       I1 is I-1,
						       junta(Aux, [(c,I1,J)], Aux2),
						       calcula_coord(R, Posicao_atual, Aux2, Movimentos).
calcula_coord([b|R], Posicao_atual, Aux, Movimentos):- !,(I,J)=Posicao_atual,
						       I1 is I+1,
						       junta(Aux, [(b,I1,J)], Aux2),
						       calcula_coord(R, Posicao_atual, Aux2, Movimentos).
calcula_coord([e|R], Posicao_atual, Aux, Movimentos):- !,(I,J)=Posicao_atual,
						       J1 is J-1,
						       junta(Aux, [(e,I,J1)], Aux2),
						       calcula_coord(R, Posicao_atual, Aux2, Movimentos).
calcula_coord([d|R], Posicao_atual, Aux, Movimentos):- !,(I,J)=Posicao_atual,
						       J1 is J+1,
						       junta(Aux, [(d,I,J1)], Aux2),
						       calcula_coord(R, Posicao_atual, Aux2, Movimentos).

% ################################################# verifica_ja_passou #########################################################%
% verifica_ja_passou/3, verifica_ja_passou(Movs, Movs_poss, Poss) - afirma que Poss e' a lista Movs_poss cujos movimentos 	%
% (celulas) ainda nao tenham sido visitados em Movs.										%
% ##############################################################################################################################%
verifica_ja_passou(Movs, Movs_poss, Poss):- verifica_ja_passou(Movs, Movs_poss, [], Poss).
verifica_ja_passou(_, [],Aux,Aux):-!.
verifica_ja_passou(Movs, [P|R],Aux,Poss):- (_,I,J)=P,
	                                   membro( (_,I,J), Movs),!,
	                                   verifica_ja_passou(Movs, R, Aux, Poss).
verifica_ja_passou(Movs, [P|R],Aux,Poss):- (_,I,J)=P,
	                                   nao_membro( (_,I,J), Movs),!,
	                                   junta(Aux, [P], Aux2),
	                                   verifica_ja_passou(Movs, R, Aux2, Poss).

% ###################################################### parte #################################################################%
% parte/6, parte(L,Ponto,Dist,Menor,Igual,Maior) - afirma que a lista L com os movimentos, os seus elementos sao distri buidos	% 
% para as listas Menor, Igual, Maior de acordo com a distancia entre o elemento da lista L e o Ponto for respetivamente Menor, 	%
% Igual, Maior que Dist.													%
% ##############################################################################################################################%
parte([],_,_,[],[],[]):-!.
parte([P|R], (X,Y), Dist, [P|Menor], Igual, Maior):- (_,I,J)=P,
				                     distancia((I,J), (X,Y), Ndist),
						     Ndist < Dist,!,
						     parte(R, (X,Y), Dist, Menor, Igual, Maior).
parte([P|R], (X,Y), Dist, Menor, [P|Igual], Maior):- (_,I,J)=P,
				                     distancia((I,J), (X,Y), Ndist),
						     Ndist = Dist,!,
						     parte(R, (X,Y), Dist, Menor, Igual, Maior).
parte([P|R], (X,Y), Dist, Menor, Igual, [P|Maior]):- (_,I,J)=P,
				                     distancia((I,J), (X,Y), Ndist),
						     Ndist > Dist,!,
						     parte(R, (X,Y), Dist, Menor, Igual, Maior).

% ############################################ ordena_acordo_distancia #########################################################%
% ordena_acordo_distancia/4, ordena_acordo_distancia(L,Res,Ponto,Tipo) - afirma que Res e' a lista ordenada conforme o Tipo	%
% (crescente/decrescente) tendo em conta a distancia ao Ponto. Obs: Utiliza o algoritmo de ordenacao Quicksort.			%
% ##############################################################################################################################%
ordena_acordo_distancia([],[],_,_):-!.
ordena_acordo_distancia([P|R],Res, (X,Y), crescente):- (_,I,J)=P,
                                                       distancia((I,J), (X,Y), Dist),
						       parte(R, (X,Y), Dist, Menor, Igual, Maior),
						       ordena_acordo_distancia(Menor, Res_menor, (X,Y), crescente),
						       ordena_acordo_distancia(Maior, Res_maior, (X,Y), crescente),
						       junta(Res_menor, [P|Igual], Res_intermedio),
						       junta(Res_intermedio, Res_maior, Res),!.
ordena_acordo_distancia([P|R],Res, (X,Y), decrescente):- (_,I,J)=P,
                                                         distancia((I,J),(X,Y),Dist),
						         parte(R, (X,Y), Dist, Menor, Igual, Maior),
						         ordena_acordo_distancia(Menor, Res_menor, (X,Y), decrescente),
						         ordena_acordo_distancia(Maior, Res_maior, (X,Y), decrescente),
						         junta(Res_maior, [P|Igual], Res_intermedio),
						         junta(Res_intermedio, Res_menor, Res),!.


% ##############################################################################################################################%
% ################################################# Operadores com listas ######################################################%
% ##############################################################################################################################%
% ##################################################### membro #################################################################%
% membro/2, membro(X,L) afirma que X e' um elemento da lista L.									%
% ##############################################################################################################################%
membro(X, [X|_]).
membro(X, [_|R]):-membro(X,R).

% ################################################## nao_membro ################################################################%
% nao_membro/2, nao_membro(X,L) afirma que X nao e' um elemento da lista L.							%
% ##############################################################################################################################%
nao_membro(_, []):-!.
nao_membro(X, [P|R]):- X\=P,
	               nao_membro(X,R).

% ##################################################### junta ##################################################################%
% junta/3, junta(X,Y,Z) - afirma que Z e' a lista que resulta de juntar	X a Y.							% 
% ##############################################################################################################################%
junta([],L,L):-!.
junta([P|R], L1, [P|R1]):- junta(R, L1, R1).

% ################################################### escolhe ##################################################################%
% escolhe/3, escolhe(L1,E,L2) - afirma que L2 e a lista obtida de L1 removendo o elemento E.					%
% ##############################################################################################################################%
escolhe(L1,E,L2):- escolhe(L1,E,[],L2).
escolhe([],_,Aux,Aux):- !.
escolhe([P|R],P,Aux,L2):- escolhe(R, P, Aux, L2),!.
escolhe([P|R],E,Aux,L2):- junta(Aux, [P], Aux2),
	                  escolhe(R, E, Aux2, L2).

% ################################################### enesimo ##################################################################%
% enesimo/3, enesimo(N,L,X) - afirma que o enesimo elemento da lista L e' X. Obs: Devolve false se N for maior que o tamanho da %
% lista.															%
% ##############################################################################################################################%
enesimo(1,[P|_],P):-!.
enesimo(N,[_|R],X):- M is N-1,
		     enesimo(M,R,X).

% ################################################# diferenca_conjunto #########################################################%
% diferenca_conjunto/3, diferenca_conjunto(L1,L2,L3) - afirma que L3 e' a lista L1 cujos elementos nao aparecem em L2.		%
% ##############################################################################################################################%
diferenca_conjunto(L1,[],L1):-!.
diferenca_conjunto(L1,[P|R],L3):- escolhe(L1,P,L),
				  diferenca_conjunto(L,R,L3).