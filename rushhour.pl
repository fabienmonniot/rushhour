% ===================== %
%       RUSH HOUR       %
% ===================== %

% Auteurs : Julien Fourcade & Fabien Monniot

% Initialisation
% --------------

:- encoding(utf8).

:- dynamic vehicule/5.
:- dynamic score/1.
:- dynamic defi/1.

% Commandes
% ---------

demarrer :- afficheTitre, afficheDefis, afficheGrille.

recommencer :-  retractall(score(_)), retractall(vehicule(_,_,_,_,_)), defi(Defi), 
                atom_concat(Defi, '.pl', Fichier), atom_concat('scenarios/', Fichier, Chemin), consult(Chemin), 
                assert(score(0)), afficheGrille.

rejouer :- retractall(score(_)), retractall(defi(_)), retractall(vehicule(_,_,_,_,_)), demarrer.

quitter :- halt.

% Déclaration des prédicats du jeu
% --------------------------------

orientation(hor).
orientation(ver).

couleur(x).

couleur(j).
couleur(r).
couleur(m).
couleur(b).
couleur(g).
couleur(o).
couleur(n).
couleur(s).
couleur(p).
couleur(f).
couleur(l).

case(X,Y) :- integer(X), integer(Y), X >= 1, X =< 6, Y >= 1, Y =< 6.
occupee(case(X,Y), C) :- vehicule(X, Y, _, _, C).
occupee(case(X,Y), C) :- X1 is X-1, vehicule(X1, Y, hor, _, C).
occupee(case(X,Y), C) :- X2 is X-2, vehicule(X2, Y, hor, 3, C).
occupee(case(X,Y), C) :- Y1 is Y-1, vehicule(X, Y1, ver, _, C).
occupee(case(X,Y), C) :- Y2 is Y-2, vehicule(X, Y2, ver, 3, C).

% Affichage
% ---------

clear :- write('\e[2J').

afficheTitre :- clear, 
                writeln('###########################'),
                writeln('##       RUSH HOUR       ##'),
                writeln('###########################\n').

afficheDefis :- writeln('\nLes défis disponibles sont : '),
                writeln(' 1 - Facile'),
                writeln(' 2 - Facile'),
                writeln(' 3 - Facile'),
                writeln(' 4 - Moyen'),
                writeln(' 5 - Moyen'),
                writeln(' 6 - Moyen'),
                writeln(' 7 - Difficile'),
                writeln(' 8 - Difficile'),
                writeln(' 9 - Difficile\n'),
                writeln('Entrez le numéro du défi choisi (suivi d\'un point) : '), read(Defi), 
                atom_concat(Defi, '.pl', Fichier), atom_concat('scenarios/', Fichier, Chemin), consult(Chemin),
                assert(score(0)), assert(defi(Defi)).

afficheDefiCourant :- write('Défi n°'), defi(D), writeln(D).
afficheScore :- write('Score : '), score(S), write(S), write('\n\n').

afficheLigne :- write('\n-------------------------\n').

afficheCase(case(6,3)) :- occupee(case(6,3), C), write(' '), write(C), write('  ').
afficheCase(case(6,3)) :- write('    ').

afficheCase(case(X,Y)) :- occupee(case(X,Y), C), write(' '), write(C), write(' |').
afficheCase(case(_,_)) :- write('   |').

affiche(case(1,1)) :- afficheLigne, write('|'), afficheCase(case(1,1)), affiche(case(2,1)).
affiche(case(6,6)) :- afficheCase(case(6,6)), afficheLigne, !.

affiche(case(1,Y)) :- write('|'), afficheCase(case(1,Y)), affiche(case(2, Y)).
affiche(case(6,Y)) :- afficheCase(case(6,Y)), Y1 is Y+1, afficheLigne, affiche(case(1, Y1)).
affiche(case(X,Y)) :- afficheCase(case(X,Y)), X1 is X+1, affiche(case(X1, Y)).

afficheConsignes :- writeln('\nVous pouvez déplacer un véhicule en tapant "deplacer(couleur, sens).".'),
                    writeln('avec la couleur étant la lettre affichée et le sens étant gauche, droite, haut ou bas.'),
                    writeln('Exemple : deplacer(x, droite).\n'),
                    writeln('Vous pouvez stopper le jeu à tout moment en tapant "quitter.",'),
                    writeln('recommencer le défi avec "recommencer." ou rejouer un autre défi en tapant "rejouer.".\n').

afficheGrille :- afficheTitre, afficheDefiCourant, afficheScore, affiche(case(1,1)), afficheConsignes, !.

victoire :- afficheTitre, write('Félicitations ! Vous avez gagné en '), score(S), write(S), writeln(' coups.\n'),
            writeln('Tapez "quitter." pour stopper le jeu,'),
            writeln('recommencez le défi avec "recommencer.",'),
            writeln('ou rejouez un autre défi en tapant "rejouer.".\n').

% Mouvements
% ----------

incrementeScore :- retract(score(S)), S1 is S+1, asserta(score(S1)).

sens(gauche).
sens(droite).
sens(haut).
sens(bas).

deplacer(x, droite) :-  vehicule(5, 3, hor, _, x), 
                        victoire.

deplacer(C, gauche) :-  vehicule(X, Y, hor, L, C), 
                        X1 is X-1, 
                        case(X1, Y), 
                        not(occupee(case(X1, Y), _)),
                        retract(vehicule(X, Y, hor, L, C)),
                        asserta(vehicule(X1, Y, hor, L, C)),
                        incrementeScore,
                        afficheGrille.

deplacer(C, droite) :-  vehicule(X, Y, hor, L, C), 
                        XL is X+L, X1 is X+1, 
                        case(XL, Y), 
                        not(occupee(case(XL, Y), _)),
                        retract(vehicule(X, Y, hor, L, C)),
                        asserta(vehicule(X1, Y, hor, L, C)),
                        incrementeScore,
                        afficheGrille.

deplacer(C, haut) :-    vehicule(X, Y, ver, L, C), 
                        Y1 is Y-1, 
                        case(X, Y1), 
                        not(occupee(case(X, Y1), _)),
                        retract(vehicule(X, Y, ver, L, C)),
                        asserta(vehicule(X, Y1, ver, L, C)),
                        incrementeScore,
                        afficheGrille.

deplacer(C, bas) :-     vehicule(X, Y, ver, L, C), 
                        YL is Y+L, Y1 is Y+1, 
                        case(X, YL), 
                        not(occupee(case(X, YL), _)),
                        retract(vehicule(X, Y, ver, L, C)),
                        asserta(vehicule(X, Y1, ver, L, C)),
                        incrementeScore,
                        afficheGrille.
