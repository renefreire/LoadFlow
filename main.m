% ANSISPOT - Programa para An�lise de Sistemas de Pot�ncia
% 
% Autor: Rene Cruz Freire
% E-mail: b1.rene.cruz@gmail.com

clc;
clear;

disp('------------------------------------------------------------------');
disp('****************************ANSISPOT******************************');
disp('------------------------------------------------------------------');
disp('Programa para An�lise de Sistemas de Pot�ncia em Regime Permanente');

%--------------------------------------------------------------------------
% Escolha do formato do arquivo do sistema de pot�ncia
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
        error('Escolha inv�lida. Tente novamente');
end

%--------------------------------------------------------------------------
% Inser��o do nome do arquivo de rede a ser convertido para o formato 
% padr�o do MATLAB (.m)
%--------------------------------------------------------------------------
disp(' ');
nome_arquivo = input('Nome do arquivo (sem extens�o): ','s');
caminho_arquivo = [nome_arquivo,'.pwf'];

% Convers�o dos arquivos atrav�s de script perl
perl(filtro,caminho_arquivo);

% Carregando a rede el�trica rec�m-convertida
% extensao = '.m';
inicial = 'd_';
rede_eletrica = [inicial,nome_arquivo];
run(rede_eletrica);

%--------------------------------------------------------------------------
% Par�metros da rede e c�lculo de Ybarra
%--------------------------------------------------------------------------
[param] = parametro(rede);
[param] = ybarra(param,rede);

%--------------------------------------------------------------------------
% Tipo de estudo desejado
%--------------------------------------------------------------------------
disp(' ');
disp('Qual estudo deseja executar na referida rede el�trica?');
disp(' ');
disp('1 - Fluxo de Pot�ncia');
disp('2 - An�lise de Conting�ncias Simples');
disp('3 - Fluxo de Pot�ncia �timo');
disp(' ');
estudo = input('Estudo escolhido -> ');
switch estudo
    case 1
        % Fluxo de Pot�ncia
        [flow, stat, param, inj] = fluxo(rede,param,nome_arquivo);
    case 2
        % An�lise de Conting�ncias
        [cont, viol] = contingencias(rede,param,nome_arquivo);
    case 3
        % Fluxo de Pot�ncia �timo
        FPORS(rede,param,nome_arquivo);
    otherwise
        % Mensagem de erro
        error('Escolha inv�lida. Tente novamente');
end
