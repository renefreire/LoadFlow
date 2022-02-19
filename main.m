% ANSISPOT - Programa para Análise de Sistemas de Potência
% 
% Autor: Rene Cruz Freire
% E-mail: b1.rene.cruz@gmail.com

clc;
clear;

disp('------------------------------------------------------------------');
disp('****************************ANSISPOT******************************');
disp('------------------------------------------------------------------');
disp('Programa para Análise de Sistemas de Potência em Regime Permanente');

%--------------------------------------------------------------------------
% Escolha do formato do arquivo do sistema de potência
%--------------------------------------------------------------------------
disp(' ');
disp('Informe o formato do arquivo de rede:');
disp(' ');
disp('1 - CEPEL(.pwf)');
disp('2 - IEEE(.cdf)');
disp(' ');
formato = input('Formato escolhido -> ');
switch formato
    case 1
        % Formato CEPEL
        filtro = 'filtro_cepel';
        extensao = '.pwf';
    case 2
        % Formato IEEE
        filtro = 'filtro_ieee';
        extensao = '.cdf';
    otherwise
        % Mensagem de erro
        error('Escolha inválida. Tente novamente');
end

%--------------------------------------------------------------------------
% Inserção do nome do arquivo de rede a ser convertido para o formato 
% padrão do MATLAB (.m)
%--------------------------------------------------------------------------
disp(' ');
nome_arquivo = input('Nome do arquivo (sem extensão): ','s');
caminho_arquivo = [nome_arquivo,'.pwf'];

% Conversão dos arquivos através de script perl
perl(filtro,caminho_arquivo);

% Carregando a rede elétrica recém-convertida
% extensao = '.m';
inicial = 'd_';
rede_eletrica = [inicial,nome_arquivo];
run(rede_eletrica);

%--------------------------------------------------------------------------
% Parâmetros da rede e cálculo de Ybarra
%--------------------------------------------------------------------------
[param] = parametro(rede);
[param] = ybarra(param,rede);

%--------------------------------------------------------------------------
% Tipo de estudo desejado
%--------------------------------------------------------------------------
disp(' ');
disp('Qual estudo deseja executar na referida rede elétrica?');
disp(' ');
disp('1 - Fluxo de Potência');
disp('2 - Análise de Contingências Simples');
disp('3 - Fluxo de Potência Ótimo');
disp(' ');
estudo = input('Estudo escolhido -> ');
switch estudo
    case 1
        % Fluxo de Potência
        [flow, stat, param, inj] = fluxo(rede,param,nome_arquivo);
    case 2
        % Análise de Contingências
        [cont, viol] = contingencias(rede,param,nome_arquivo);
    case 3
        % Fluxo de Potência Ótimo
        FPORS(rede,param,nome_arquivo);
    otherwise
        % Mensagem de erro
        error('Escolha inválida. Tente novamente');
end
