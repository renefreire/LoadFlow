function [stat, flow, inj] = fluxoDC(rede,param)

tic; % In�cio da contagem de tempo

% Tipos de barra
% 1 - PQ
% 2 - PV
% 3 - Swing
[inj.tipo] = tipo_barra(rede,param);

% Pot�ncia injetada nas barras do sistema de pot�ncia
Pbarra = zeros(param.nBarras,1);

m = find(inj.tipo == 1);
k = 1:numel(m);
Pbarra(m) = (-1)*rede.PQ(k,3);

i = find(inj.tipo == 2);
j = 1:numel(i);
Pbarra(i) = rede.PV(j,3);

sw = find(inj.tipo == 3);

Pbarra(sw) = [];

% Determina��o dos �ngulos de fase das tens�es nas barras desprezando as
% perdas
Thm = param.Binv*Pbarra;
Th = zeros(param.nBarras,1);
Th(1:sw-1) = Thm(1:sw-1);
Th(sw+1:end) = Thm(sw:end);
Th(sw) = 0;
clear Thm;

% C�lculo das perdas totais nos ramos distribu�das como inje��es nas barras
flow.Lij = zeros(param.nLinhas,1);
for l = 1:param.nLinhas
    d = param.DE(l);
    p = param.PARA(l);
    flow.Lij(l) = param.g(l)*((Th(d) - Th(p))^2);
end

Perda = zeros(param.nBarras - 1,1);
for b = 1:param.nBarras
    if b < sw
        for l = 1:param.nLinhas
            d = param.DE(l);
            p = param.PARA(l);
            if (d == b)||(p == b)
                Perda(b) = Perda(b) + flow.Lij(l)/2;
            end
        end
    elseif b > sw
        for l = 1:param.nLinhas
            d = param.DE(l);
            p = param.PARA(l);
            if (d == b)||(p == b)
                Perda(b-1) = Perda(b-1) + flow.Lij(l)/2;
            end
        end
    end
end

% Determina��o dos �ngulos de fase das tens�es nas barras considerando as
% perdas, inje��o de pot�ncia l�quida em cada barra e perdas associadas a
% cada ramo
Pliq = Pbarra - Perda;
Theta = param.Binv*Pliq;

stat.ang = zeros(param.nBarras,1);
stat.ang(1:sw-1) = Theta(1:sw-1);
stat.ang(sw+1:end) = Theta(sw:end);
stat.ang(sw) = 0;
clear Theta;

flow.Pi = zeros(param.nBarras,1);
flow.Pi(1:sw-1) = Pliq(1:sw-1);
flow.Pi(sw+1:end) = Pliq(sw:end);
flow.Pi(sw) = -sum(Pbarra) + sum(Perda);
clear Pbarra;

inj.Ploss = zeros(param.nBarras,1);
inj.Ploss(1:sw-1) = Perda(1:sw-1);
inj.Ploss(sw+1:end) = Perda(sw:end);
inj.Ploss(sw) = 0;
clear Perda;

% Fluxo de pot�ncia ativa ns linhas de transmiss�o
flow.Pij = zeros(param.nBarras,param.nBarras);
x = rede.Linhas(:,10);
for l = 1:param.nLinhas
    d = param.DE(l);
    p = param.PARA(l);
    flow.Pij(d,p) = (stat.ang(d) - stat.ang(p))/x(l);
    flow.Pij(p,d) = -flow.Pij(d,p) + flow.Lij(l);
end

% Pot�ncia injetada nas barras do sistema de pot�ncia
inj.Pload = zeros(param.nBarras,1); % Pot�ncia ativa demandada
inj.Pger = zeros(param.nBarras,1); % Pot�ncia ativa gerada

m = find(inj.tipo == 1);
n = 1:numel(m);
inj.Pload(m) = rede.PQ(n,3);

i = find(inj.tipo == 2);
j = 1:numel(i);
inj.Pger(i) = rede.PV(j,3);

k = find(inj.tipo == 3);
inj.Pger(k) = flow.Pi(k);

stat.tempo = toc; % Encerramento da contagem de tempo

fprintf('\nFluxo de Pot�ncia Linearizado executado com sucesso\n');
fprintf('Tempo de execu��o do Fluxo de Pot�ncia Linearizado: %f seg\n',stat.tempo);
