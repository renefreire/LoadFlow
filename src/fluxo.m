% Fun??o que gerencia as opera??es matem?ticas para a resolu??o do fluxo de
% pot?ncia

function [flow, stat, param, rede, inj] = fluxo(rede,param,nome_arquivo,estudo)

disp(' ');
disp('An?lise do Fluxo de Pot?ncia');

switch estudo
    case 1
        disp('M?todo de Newton-Raphson');
    case 2
        disp('M?todo Desacoplado');
    case 3
        disp('M?todo Desacoplado R?pido');
    otherwise
        error('Escolha inv?lida');
end

% Tipos de barra
% 1 - PQ
% 2 - PV
% 3 - Swing
[inj.tipo] = tipo_barra(rede,param);

% Pot?ncia injetada nas barras do sistema de pot?ncia
inj.Pload = zeros(param.nBarras,1); % Pot?ncia ativa demandada
inj.Qload = zeros(param.nBarras,1); % Pot?ncia reativa demandada
inj.Pger = zeros(param.nBarras,1); % Pot?ncia ativa gerada
inj.Qger = zeros(param.nBarras,1); % Pot?ncia reativa gerada
k = 1;
n = 1;
for m = 1:param.nBarras
    if inj.tipo(m) == 1
        inj.Pload(m) = rede.PQ(k,3);
        inj.Qload(m) = rede.PQ(k,4);
        k = k + 1;
    elseif inj.tipo(m) == 2
        inj.Pger(m) = rede.PV(n,3);
        n = n + 1;
    end
end

inj.Pesp = inj.Pger - inj.Pload; % Inje??o l?quida de pot?ncia ativa
inj.Qesp = inj.Qger - inj.Qload; % Inje??o l?quida de pot?ncia reativa 

% Limites de reativos injetados nas barras
inj.Qmin = -inf(param.nBarras,1);
inj.Qmax = inf(param.nBarras,1);
k = 1;
n = 1;
for m = 1:param.nBarras
    if inj.tipo(m) == 2
        inj.Qmin(m) = rede.PV(k,6);
        inj.Qmax(m) = rede.PV(k,5);
        k = k + 1;        
    elseif inj.tipo(m) == 3
        inj.Qmin(m) = rede.SW(n,6);
        inj.Qmax(m) = rede.SW(n,5);
        n = n + 1;
    end
end

% Execu??o do m?todo de Newton-Raphson
[stat, param] = newton_raphson(rede,param,inj,estudo);

% C?lculo do Fluxo de Pot?ncia
[flow, inj] = fluxo_potencia(param,stat,inj);

% Escrevendo o relat?rio de execu??o do programa
relatorio_FP(flow,param,stat,inj,rede,nome_arquivo,estudo);
