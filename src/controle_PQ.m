% Função para realizar o controle da tensão calculada nas barras PQ

function [inj, param, stat] = controle_PQ(param,inj,stat,tipo_esp,rede)

for n = 1:param.nBarras
    if inj.tipo(n) == 1 % Caso seja barra PQ, verificar tensão calculada
        if tipo_esp(n) == inj.tipo(n) % Caso a barra seja naturalmente PQ, faça
            if stat.Vbarra(n) < rede.Barras(n,5)
                stat.Vbarra(n) = rede.Barras(n,5); % Tensão violada fixada no mínimo
                inj.tipo(n) = 2; % Mudança do tipo de barra para PV
            elseif stat.Vbarra(n) > rede.Barras(n,6)
                stat.Vbarra(n) = rede.Barras(n,6); % Tensão violada fixada no máximo
                inj.tipo(n) = 2; % Mudança do tipo de barra para PV
            end
        else % Caso a barra seja PQ convertida, faça
            if (inj.Qesp(n) == inj.Qmax(n) - inj.Qload(n))&&(stat.Vbarra(n) > rede.Barras(n,3))
%                 stat.Vbarra(n) = rede.Barras(n,3);
                inj.tipo(n) = 2; % Retorno da barra para PV
            elseif (inj.Qesp(n) == inj.Qmin(n) - inj.Qload(n))&&(stat.Vbarra(n) < rede.Barras(n,3))
%                 stat.Vbarra(n) = rede.Barras(n,3);
                inj.tipo(n) = 2; % Retorno da barra para PV
            end
        end
    end
end
param.nPQ = length(find(inj.tipo == 1));
param.nPV = length(find(inj.tipo == 2));