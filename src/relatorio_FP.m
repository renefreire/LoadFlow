% Fun��o que escreve o relat�rio da execu��o do fluxo de pot�ncia

function [] = relatorio_FP(flow,param,stat,inj,rede,nome_arquivo,estudo)

relat = ['ANSISPOT_FP_',nome_arquivo,'.txt'];
rel = fopen(relat,'wt');

fprintf(rel,'An�lise do Fluxo de Pot�ncia\n');
switch estudo
    case 1
        fprintf(rel,'M�todo de Newton-Raphson Completo\n');
    case 2
        fprintf(rel,'M�todo de Newton-Raphson Desacoplado\n');
    case 3
        fprintf(rel,'M�todo de Newton-Raphson Desacoplado R�pido\n');
    otherwise
        error('Escolha inv�lida');
end
fprintf(rel,'\n');
fprintf(rel,'Autor: Rene Cruz Freire\n');
fprintf(rel,'Email: b1.rene.cruz@gmail.com\n');
fprintf(rel,'\n\n');
fprintf(rel,'DADOS DA REDE EL�TRICA\n');
fprintf(rel,'\n');
fprintf(rel,'N�mero de barras:      %d\n',param.nBarras);
fprintf(rel,'N�mero de linhas:      %d\n',param.nLinhas);
fprintf(rel,'N�mero de geradores:   %d\n',(param.nPV+1));
fprintf(rel,'N�mero de cargas:      %d\n',param.nPQ);
fprintf(rel,'\n');
fprintf(rel,'RELAT�RIO DA SIMULA��O\n');
fprintf(rel,'\n');
fprintf(rel,'N�mero de itera��es:               %d\n',stat.iter);
fprintf(rel,'Res�duo m�x. de pot. ativa :       %f p.u.\n',max(abs(stat.dP)));
fprintf(rel,'Res�duo m�x. de pot. reativa:      %f p.u.\n',max(abs(stat.dQ)));
fprintf(rel,'Pot�ncia base:                     %d MVA\n',param.Sbase);
fprintf(rel,'\n');
fprintf(rel,'PERFIL DE TENS�O E INJE��O DE POT�NCIA NAS BARRAS\n');
fprintf(rel,'\n');
fprintf(rel,'----------------------------------------------------------------------------------------------------------\n');
fprintf(rel,'| Barra |   V    | �ngulo  |      Pot. L�quida       |        Pot. Gerada      |      Pot. Consumida     |\n');
fprintf(rel,'|   No  | [p.u.] |  [rad]  |    [MW]    |   [Mvar]   |    [MW]    |   [Mvar]   |    [MW]    |   [Mvar]   |\n');
for m = 1:param.nBarras
    fprintf(rel,'----------------------------------------------------------------------------------------------------------\n');
    fprintf(rel,' %5g', rede.Barras(m,1)); 
    fprintf(rel,' %9.5f', stat.Vbarra(m)); 
    fprintf(rel,' %9.5f', stat.ang(m));
    fprintf(rel,'   %9.3f', flow.Pi(m)*param.Sbase); 
    fprintf(rel,'    %9.3f', flow.Qi(m)*param.Sbase); 
    fprintf(rel,'    %9.3f', inj.Pger(m)*param.Sbase); 
    fprintf(rel,'    %9.3f', inj.Qger(m)*param.Sbase); 
    fprintf(rel,'    %9.3f', inj.Pload(m)*param.Sbase); 
    fprintf(rel,'    %9.3f', inj.Qload(m)*param.Sbase); 
    fprintf(rel,'\n');
end
fprintf(rel,'----------------------------------------------------------------------------------------------------------\n');
fprintf(rel,'\n');
fprintf(rel,'FLUXO DE POT�NCIA (F.P.) E PERDAS NAS LINHAS\n');
fprintf(rel,'\n');
fprintf(rel,'---------------------------------------------------------------------------------------------------------------\n');
fprintf(rel,'| DE    | PARA  |       F.P. direto       | DE    | PARA  |       F.P. inverso      |          Perdas         |\n');
fprintf(rel,'| Barra | Barra |    [MW]    |   [Mvar]   | Barra | Barra |    [MW]    |   [Mvar]   |    [MW]    |   [Mvar]   |\n');
for m = 1:param.nLinhas
    p = rede.Linhas(m,1); 
    q = rede.Linhas(m,2);
    i = param.DE(m); 
    j = param.PARA(m);
    fprintf(rel,'---------------------------------------------------------------------------------------------------------------\n');
    fprintf(rel,' %5g', p); 
    fprintf(rel,'   %5g', q); 
    fprintf(rel,'    %9.3f', flow.Pij(i,j)*param.Sbase); 
    fprintf(rel,'    %9.3f', flow.Qij(i,j)*param.Sbase); 
    fprintf(rel,'   %5g', q); 
    fprintf(rel,'   %5g', p); 
    fprintf(rel,'    %9.3f', flow.Pij(j,i)*param.Sbase); 
    fprintf(rel,'    %9.3f', flow.Qij(j,i)*param.Sbase);
    fprintf(rel,'    %9.3f', flow.Lpij(m)*param.Sbase); 
    fprintf(rel,'    %9.3f', flow.Lqij(m)*param.Sbase);
    fprintf(rel,'\n');
end
fprintf(rel,'---------------------------------------------------------------------------------------------------------------\n');
fprintf(rel,'\n');
fprintf(rel,'RESUMO DOS RESULTADOS\n');
fprintf(rel,'\n\n');
fprintf(rel,'GERA��O TOTAL\n');
fprintf(rel,'\n');
fprintf(rel,'Pot�ncia ativa:         %9.3f MW\n',sum(inj.Pger)*param.Sbase);
fprintf(rel,'Pot�ncia reativa:       %9.3f Mvar\n',sum(inj.Qger)*param.Sbase);
fprintf(rel,'\n');
fprintf(rel,'DEMANDA TOTAL\n');
fprintf(rel,'\n');
fprintf(rel,'Pot�ncia ativa:         %9.3f MW\n',sum(inj.Pload)*param.Sbase);
fprintf(rel,'Pot�ncia reativa:       %9.3f Mvar\n',sum(inj.Qload)*param.Sbase);
fprintf(rel,'\n');
fprintf(rel,'PERDAS TOTAIS\n');
fprintf(rel,'\n');
fprintf(rel,'Pot�ncia ativa:         %9.3f MW\n',sum(flow.Lpij)*param.Sbase);
fprintf(rel,'Pot�ncia reativa:       %9.3f Mvar\n',sum(flow.Lqij)*param.Sbase);

fclose(rel);