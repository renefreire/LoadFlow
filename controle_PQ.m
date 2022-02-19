% Fun��o para realizar o controle da tens�o calculada nas barras PQ

function [inj, param, stat] = controle_PQ(param,inj,stat,tipo_esp,rede)

for n = 1:param.nBarras
    if inj.tipo(n) == 1 % Caso seja barra PQ, verificar tens�o calculada
        if tipo_esp(n) == inj.tipo(n) % Caso a barra seja naturalmente PQ, fa�a
            if stat.Vbarra(n) < rede.Barras(n,5)
                stat.Vbarra(n) = rede.Barras(n,5); % Tens�o violada fixada no m�nimo
                inj.tipo(n) = 2; % Mudan�a do tipo de barra para PV
            elseif stat.Vbarra(n) > rede.Barras(n,6)
                stat.Vbarra(n) = rede.Barras(n,6); % Tens�o violada fixada no m�ximo
                inj.tipo(n) = 2; % Mudan�a do tipo de barra para PV
            end
        else % Caso a barra seja PQ convertida, fa�a
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