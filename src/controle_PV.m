% Função para realizar o controle do reativo calculado nas barras PV

function [inj, param, stat] = controle_PV(param,inj,stat,Qcal,tipo_esp,rede)

for n = 1:param.nBarras
    if inj.tipo(n) == 2 % Caso seja barra PV, verificar reativo
        if tipo_esp(n) == inj.tipo(n) % Caso a barra seja naturalmente PV, faça
            if (Qcal(n) + inj.Qload(n)) < inj.Qmin(n)
                inj.Qesp(n) = inj.Qmin(n) - inj.Qload(n); % Reativo violado fixado no mínimo
                inj.tipo(n) = 1; % Mudança do tipo de barra para PQ
            elseif (Qcal(n) + inj.Qload(n)) > inj.Qmax(n)
                inj.Qesp(n) = inj.Qmax(n) - inj.Qload(n); % Reativo violado fixado no máximo               
                inj.tipo(n) = 1; % Mudança do tipo de barra para PQ
            end
        else % Caso a barra seja PV convertida, faça
            if (stat.Vbarra(n) == rede.Barras(n,5))&&(Qcal(n) < inj.Qesp(n))
                inj.tipo(n) = 1; % Retorno da barra para PQ
            elseif (stat.Vbarra(n) == rede.Barras(n,6))&&(Qcal(n) > inj.Qesp(n))
                inj.tipo(n) = 1; % Retorno da barra para PQ
            end
        end
        
    end
end
param.nPQ = length(find(inj.tipo == 1));
param.nPV = length(find(inj.tipo == 2));