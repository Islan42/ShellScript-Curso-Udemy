#!/bin/bash
#
# ipsum.sh - Gerador de Lorem Ipsum
#
# Autor: Islan Victhor
# Site:  github.com/Islan42
# ------------------------------------- #
#
# Gerador de textos aleatórios estilo Lorem Ipsum
#
# ./ipsum.sh [OPÇÃO]
#
# ------------------------------------- #
#
# Histórico
# v1.0 21/03/2026, Islan:
#   - Versão inicial incluindo opções [hmn]
# v1.1 21/03/2026, Islan:
#   - Adição das opções [vd]
#
# ---------------VARIÁVEIS------------- #

ARQUIVO_CONFIGURACAO="ipsum.conf"

CHAVE_MAIUSCULO=0
CHAVE_VERBOSO=0
CHAVE_DEFAULT=0
N_PALAVRAS=50

COR_VERMELHA="\033[31;1m"
NORMAL_COLOR="\033[0m"

HELP_MSG="
ipsum.sh

DESCRIÇÃO
  Gerador de textos aleatórios no estilo Lorem Ipsum

  $0 [OPÇÃO]

OPÇÕES
  -h            Exibe a mensagem de ajuda
  -m            TODAS AS LETRAS MAIÚSCULAS
  -n [n]        Retorna um número [n] de palavras. Deve ser  maior ou igual a 5.
  -v            Antes do texto, gera uma linha com o número de palavras
  -d            Começa obrigatoriamente com 'Lorem ipsum dolor sit amet'

"

BANCO_PALAVRAS=(lorem ipsum dolor sit amet erebus massonicus
cadernus imparabilis deterministicus pilantrinus amabilis
civicus partenom damascus sisifus brutalitis mhinus eclesiastis
aracnidium canis lupus segregatium vilipendium)

MENSAGEM_FINAL=""

# ----------------TESTES--------------- #

[ ! -r "$ARQUIVO_CONFIGURACAO" ] && echo -e "${COR_VERMELHA}ERRO: ${NORMAL_COLOR}Você não tem permissão de acesso ao arquivo." && exit 1

while read -r linha
do
  [ "$(echo "$linha" | cut -c 1)" = "#" ] && continue
  [ ! $linha ] && continue

  parametro="$(echo $linha | cut -d = -f 1)"
  valor="$(echo $linha | cut -d = -f 2)"
  eval "$parametro=$valor"
done < "$ARQUIVO_CONFIGURACAO"

# ---------------EXECUÇÃO-------------- #

MAX_LOOP=$N_PALAVRAS

if [ $CHAVE_DEFAULT = "1" ]
then
  BANCO_PALAVRAS=(${BANCO_PALAVRAS[@]:5})
  MENSAGEM_FINAL=" ${COR_VERMELHA}Lorem ipsum dolor sit amet${NORMAL_COLOR}"
  MAX_LOOP=$(( $MAX_LOOP - 5 ))
fi

for ((i=0; i < $MAX_LOOP; i++))
do
  n_random=$(( $RANDOM % ${#BANCO_PALAVRAS[@]} )) # Gera um número entre 0 e #BANCO_PALAVRAS-1
  MENSAGEM_FINAL+=" ${BANCO_PALAVRAS[$n_random]}"
done

MENSAGEM_FINAL="${MENSAGEM_FINAL:1}"

[ $CHAVE_VERBOSO -eq 1 ] && echo "$N_PALAVRAS"
[ $CHAVE_MAIUSCULO -eq 1 ] && MENSAGEM_FINAL="$(echo $MENSAGEM_FINAL | tr [a-z] [A-Z])"

echo -e "$MENSAGEM_FINAL"
