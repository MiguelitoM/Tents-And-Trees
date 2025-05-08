% Miguel Almeida Morais 109886
:- use_module(library(clpfd)). % para poder usar transpose/2
:- set_prolog_flag(answer_write_options,[max_depth(0)]). % ver listas completas
:- ["puzzlesAcampar.pl"]. % Ficheiro dado. No Mooshak tera mais puzzles.
% Atencao: nao deves copiar nunca os puzzles para o teu ficheiro de codigo
% Segue-se o codigo


vizinhanca((L, C), Vizinhanca) :-
    % Recebe uma posicao de coordenadas (L, C) e devolve a vizinhanca.
    Lmaisum is L + 1,
    Lmenosum is L - 1,
    Cmaisum is C + 1,
    Cmenosum is C - 1,
    Vizinhanca = [(Lmenosum, C),(L, Cmenosum),(L, Cmaisum),(Lmaisum, C)].


vizinhancaAlargada((L, C), VizinhancaAlargada) :-
    % Recebe uma posicao de coordenadas (L, C) e devolve a vizinhanca alargada.
    Lmaisum is L + 1,
    Lmenosum is L - 1,
    Cmaisum is C + 1,
    Cmenosum is C - 1,
    VizinhancaAlargada = [(Lmenosum, Cmenosum),(Lmenosum, C),(Lmenosum, Cmaisum),
                                (L, Cmenosum),(L, Cmaisum),
                (Lmaisum, Cmenosum),(Lmaisum, C), (Lmaisum, Cmaisum)].


todasCelulas(Tabuleiro, TodasCelulas) :-
    % Recebe um tabuleiro e devolve uma lista de coordenadas de todo o tabuleiro.
    findall((L, C), (nth1(L, Tabuleiro, Linha), nth1(C, Linha, _)), TodasCelulas).


todasCelulas(Tabuleiro, TodasCelulas, Objecto) :-
    % Recebe um tabuleiro e um objecto e devolve um lista das coordenadas de 
    % celulas que contem este objecto. Objecto pode ser tambem uma variavel 
    % e neste caso o predicado devolve as coordenadas de celulas vazias.
    findall((L, C), (nth1(L, Tabuleiro, Linha), nth1(C, Linha, Celula), 
    ((var(Objecto), var(Celula)); (not(var(Objecto)),(Celula == Objecto)))), TodasCelulas).


contaObjectos(Lista, Objecto, N) :-
    % Este predicado auxilia o calculaObjectosTabuleiro. 
    % Recebe uma Lista com celulas e conta quantas celulas tem o Objecto.
    findall((I),(nth1(I, Lista, Celula), ((var(Objecto), var(Celula)); 
    (nonvar(Objecto), Celula == Objecto))),(L_aux)),
    length(L_aux, N).

calculaObjectosTabuleiro(T, CLinhas, Objecto) :-
    % Este predicado faz o calculaObjectosTabuleiro\4 apenas para linhas.
    same_length(T, L_Objectos),
    findall(Objecto, member(Objecto, L_Objectos), L_Objectos), 
    % Cria uma lista L_Objectos com o elemento Objecto 
    % varias vezes la para aplicar o maplist.
    maplist(contaObjectos, T, L_Objectos, CLinhas).
    % Conta cada uma das linhas e devolve a lista com os calculos.

calculaObjectosTabuleiro(T, CLinhas, CColunas, Objecto) :- 
    % Recebe um tabuleiro e um objecto e devolve a 
    % contagem desse objecto por linhas e colunas.
    calculaObjectosTabuleiro(T, CLinhas, Objecto), 
    transpose(T, T_transposta), % transpoe para aplicar o predicado para colunas.
    calculaObjectosTabuleiro(T_transposta, CColunas, Objecto).


celulaVazia(T, (L, C)) :-
    % Devolve true se a celula e vazia e false caso contrario.
    % Foi mais facil implementar o predicado de forma inversa
    % (Definir para quando a celula nao e vazia).
    \+ celulaVaziaInvertido(T, (L, C)).

celulaVaziaInvertido(T, (L, C)) :-
    nth1(L, T, Linha),
    nth1(C, Linha, Celula),
    nonvar(Celula),
    Celula \= r.


insereObjectoCelula(T, TOuR, (L, C)) :-
    % Insere um objecto TendaOuRelva nas coordenadas (L, C).
    % Nao faz nada caso ja exista um objecto nesta celula.
    nth1(L, T, Linha),
    nth1(C, Linha, Celula),
    ((var(Celula), Celula = TOuR);
    (nonvar(Celula))).


insereObjectoEntrePosicoes(T, TOuR, (L, C1), (L, C2)) :- 
    % O predicado insere uma tenda ou relva entre duas coordenadas.
    ((C1 < C2, Coluna is C1);
    (C1 >= C2, Coluna is C2)),
    % Coluna toma o valor minimo de C1 e C2.
    insereObjectoEntrePosicoes(T, TOuR, (L, C1), (L, C2), Coluna).

insereObjectoEntrePosicoes(T, TOuR, (L, C1), (L, C2), Coluna) :-
    % Este predicado e chamado com todos os valores de Coluna 
    % entre C1 e C2 e para cada valor de Coluna e inserido 
    % um objecto TOuR na posicao (L, Coluna).
    Coluna =< max(C1, C2), !,
    insereObjectoCelula(T, TOuR, (L, Coluna)),
    Coluna_maisum is Coluna + 1,
    insereObjectoEntrePosicoes(T, TOuR, (L, C1), (L, C2), Coluna_maisum).

insereObjectoEntrePosicoes(_, _, (_, C1), (_, C2), Coluna) :-
    % Caso terminal.
    Coluna > max(C1, C2).


preencherRelvaOuTenda(_, [], _, _).
% Caso terminal.
preencherRelvaOuTenda(T, [P|IndicesL], Tamanho, TOuR) :-
    % Este predicado recebe uma lista de indices e coloca relvas 
    % ou tendas em todas as celulas de cada linha dentro de IndicesL.
    insereObjectoEntrePosicoes(T, TOuR, (P, 1), (P, Tamanho)),
    preencherRelvaOuTenda(T, IndicesL, Tamanho, TOuR).

relva(Puzzle) :-
    % Este predicado coloca relva em todas as linhas/colunas 
    % que ja tenham atingido o numero maximo de tendas.
    Puzzle = (T, TendasL, TendasC),
    calculaObjectosTabuleiro(T, CLinhas, CColunas, t),
    length(T, L),
    nth1(1, T, Linha),
    length(Linha, C),
    % Preencher Linhas.
    findall(I, (nth1(I, TendasL, NT1), nth1(I, CLinhas, NT2), NT1 == NT2), IndicesL),
    preencherRelvaOuTenda(T, IndicesL, C, r),
    % Preencher Colunas.
    findall(I, (nth1(I, TendasC, NT1), nth1(I, CColunas, NT2), NT1 == NT2), IndicesC),
    transpose(T, T_transposta),
    preencherRelvaOuTenda(T_transposta, IndicesC, L, r).


inacessivel(_, []).
inacessivel(T, [Coordenada|Vizinhanca]) :-
    % Confirma se nao existem arvores dada uma lista de coordenadas.
    Coordenada = (L, C),
    (celulaVazia(T, Coordenada);
    (Celula \= a),
    nth1(L, T, Linha), nth1(C, Linha, Celula)),
    inacessivel(T, Vizinhanca).

inacessiveis(T) :-
    % Coloca relva em todas as celulas que nao estao adjacentes a uma arvore.
    todasCelulas(T, TodasCelulas),
    findall((L, C), (member((L,C), TodasCelulas), (vizinhanca((L, C), Vizinhanca)),
    inacessivel(T, Vizinhanca)), ColocarRelva),
    % ColocarRelva e uma lista que tem todas as coordenadas onde deve ser colocado relva.
    colocarRelva(T, ColocarRelva).

colocarRelva(_, []).
% Caso terminal.
colocarRelva(T, [Coordenada|Lista]) :-
    % Coloca relva em todas as Coordenadas de Lista.
    insereObjectoCelula(T, r, Coordenada),
    colocarRelva(T, Lista).


colocarRelva(_, [], _, _).
colocarRelva(T, [Coordenada|Lista], MaxL, MaxC) :-
    % Este predicado faz o mesmo que o anterior mas 
    % pode receber coordenadas fora do Tabuleiro sem falhar.
    % Sera util para o limpaVizinhancas.
    Coordenada = (L, C),
    L > 0, L =< MaxL, C > 0, C =< MaxC,
    insereObjectoCelula(T, r, Coordenada),
    colocarRelva(T, Lista, MaxL, MaxC).
colocarRelva(T, [Coordenada|Lista], MaxL, MaxC) :-
    Coordenada = (L, C),
    (L =< 0; L > MaxL; C =< 0; C > MaxC),
    colocarRelva(T, Lista, MaxL, MaxC).

aproveita(Puzzle) :-
    % Este predicado coloca tendas em linhas ou colunas que 
    % tenham X tendas por preencher e X celulas livres.
    Puzzle = (T, TendasL, TendasC),
    calculaObjectosTabuleiro(T, CLinhas_Livre, CColunas_Livre, _),
    calculaObjectosTabuleiro(T, CLinhas_Tendas, CColunas_Tendas, t),
    length(T, L),
    nth1(1, T, Linha),
    length(Linha, C),
    % Preencher Linhas.
    findall(I, (nth1(I, TendasL, NT1), nth1(I, CLinhas_Tendas, NT2),
    nth1(I, CLinhas_Livre, NL), NT1 - NT2 =:= NL), IndicesL),
    preencherRelvaOuTenda(T, IndicesL, C, t),
    % Preencher Colunas.
    findall(I, (nth1(I, TendasC, NT1), nth1(I, CColunas_Tendas, NT2),
    nth1(I, CColunas_Livre, NL), NT1 - NT2 =:= NL), IndicesC),
    transpose(T, T_transposta),
    preencherRelvaOuTenda(T_transposta, IndicesC, L, t).


limpaVizinhancas(Puzzle) :-
    % Coloca relva na Vizinhanca alargada de uma tenda.
    Puzzle = (T, _, _),
    todasCelulas(T, CoordTendas, t),
    findall(Coord, (member(Tenda, CoordTendas), vizinhancaAlargada(Tenda, VizinhancaAlargada),
    member(Coord, VizinhancaAlargada)), VizinhancaTotal),
    % VizinhancaTotal e a lista onde deve ser colocada relva.
    nth1(1, T, Linha1),
    length(T, L),
    length(Linha1, C),
    % L e C sao os limites do tabuleiro.
    colocarRelva(T, VizinhancaTotal, L, C).


analisaArvores(_, []).
analisaArvores(T, [Arvore| Arvores]) :-
    % Recebe uma lista de arvores e procura uma lista Livres e Tendas 
    % para as celulas Livres e para as tendas na vizinhanca da arvore. 
    vizinhanca(Arvore, Vizinhanca),
    findall((L, C), ((member((L, C), Vizinhanca)), (nth1(L, T, Linha)),
    (nth1(C, Linha, Celula)), (var(Celula))), Livres),
    findall((L, C), ((member((L, C), Vizinhanca)), (nth1(L, T, Linha)), 
    (nth1(C, Linha, Celula)), (Celula == t)), Tendas),
    gereInfoArvores(T, Tendas, Livres),
    analisaArvores(T, Arvores).

gereInfoArvores(T, Tendas, Livres) :-
    % Caso so exista uma celula Livre e nao existam tendas
    % na vizinhanca de uma arvore entao e colocada uma 
    % tenda na celula Livre. Caso contrario, nada acontece.
    length(Tendas, 0),
    length(Livres, 1),
    Livres = [Coord],
    insereObjectoCelula(T, t, Coord).
gereInfoArvores(_, Tendas, _) :-
    not(length(Tendas, 0)).
gereInfoArvores(_, _, Livres) :-
    not(length(Livres, 1)).
    
unicaHipotese(Puzzle) :-
    % Coloca uma tenda na unica posicao que permite
    % uma arvore ficar ligada a uma tenda.
    Puzzle = (T, _, _),
    todasCelulas(T, CoordArvores, a),
    analisaArvores(T, CoordArvores).


valida(LArv, LTen) :-
    % Confirma se, dado uma lista de arvores e outra de tendas, as regras mantem-se validas.
    same_length(LArv, LTen),
    maplist(vizinhanca, LArv, Vizinhancas),
    % Procura tendas que nao estao ligadas a nenhuma arvore.
    findall(I, (nth1(I, Vizinhancas, Vizinhanca), intersection(LTen, Vizinhanca, [])), Vazio),
    Vazio = [].


resolvido(Puzzle) :-
    % Este predicado confirma se um Puzzle esta resolvido. Sera o caso terminal do resolve.
    Puzzle = (T, TendasL, TendasC),
    calculaObjectosTabuleiro(T, CLinhas, CColunas, t),
    TendasL = CLinhas,
    TendasC = CColunas,
    todasCelulas(T, LTen, t),
    todasCelulas(T, LArv, a),
    valida(LArv, LTen).


resolve(Puzzle) :-
    % Este predicado recebe um Puzzle e resolve-o.
    Puzzle = (T, _, _),
    copy_term(T, Copia_T),

    % Aplicam-se as estrategias
    relva(Puzzle),
    inacessiveis(T),
    aproveita(Puzzle),
    limpaVizinhancas(Puzzle),
    unicaHipotese(Puzzle),

    % Atraves da copia feita no inicio, confirma-se se existiu 
    % alguma alteracao apos a aplicacao das estrategias. Se sim, 
    % entao aplicam-se as estrategias de novo. Se nao, inicia-se a tentativa e erro.
    todasCelulas(Copia_T, Livres1, _),
    todasCelulas(T, Livres2, _),
    length(Livres1, N1),
    length(Livres2, N2),
    !,
    (resolvido(Puzzle);
    ((N1 \== N2), resolve(Puzzle);

    % Tentativa   
    nth1(1, Livres2, Tentativa),

    (insereObjectoCelula(T, t, Tentativa),
    resolve(Puzzle);

    % Caso a tentativa falhe entao continua a resolver 
    % com uma relva no local onde a tentativa falhou.
    insereObjectoCelula(T, r, Tentativa),
    resolve(Puzzle)))).