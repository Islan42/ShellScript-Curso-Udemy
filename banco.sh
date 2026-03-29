#!/bin/bash
#
# ---------------- VARIÁVEIS --------------- #
ARQUIVO_BANCO_DE_DADOS="banco_de_dados.txt"
TEMP="temp$$"
SEP=":"


VERMELHO="\033[31;1m"
NO_COLOR="\033[0m"

# ---------------- TESTES ------------------ #

[ ! -e "$ARQUIVO_BANCO_DE_DADOS" ] && echo -e "${VERMELHO}ERRO: ${NO_COLOR}Arquivo não existe" && exit 1
[ ! -r "$ARQUIVO_BANCO_DE_DADOS" ] && echo -e "${VERMELHO}ERRO: ${NO_COLOR}Arquivo não tem permissão de leitura." && exit 1
[ ! -w "$ARQUIVO_BANCO_DE_DADOS" ] && echo -e "${VERMELHO}ERRO: ${NO_COLOR}Arquivo não tem permissão de escrita." && exit 1

# --------------- FUNÇÕES ------------------ #

ListarUsuarios () {
  while read -r linha
  do
    [ "$(echo $linha | cut -c1)" == "#" ] && continue
    [ ! "$linha" ] && continue

    local id="$(echo $linha | cut -d $SEP -f 1)"
    local nome="$(echo $linha | cut -d $SEP -f 2)"
    local email="$(echo $linha | cut -d $SEP -f 3)"
    echo "$id - $nome - $email"
  done < "$ARQUIVO_BANCO_DE_DADOS"
}

ValidarExistenciaUsuario () {
  grep -i -q "$1$SEP" "$ARQUIVO_BANCO_DE_DADOS"
}

InserirUsuario () {
  if ValidarExistenciaUsuario "$1"
  then
    echo "Usuário já existe." && exit 1
  else
    ultimo_indice=$(grep -E -v "^#|^$" "$ARQUIVO_BANCO_DE_DADOS" | sort -n | tail -n 1 | cut -d "$SEP" -f 1)
    novo_indice=$(($ultimo_indice + 1))
    echo "$novo_indice$SEP$1$SEP$2" >> "$ARQUIVO_BANCO_DE_DADOS"
  fi
}

RemoverUsuario () {
  if ValidarExistenciaUsuario "$1"
  then
    grep -v -i "$1$SEP" "$ARQUIVO_BANCO_DE_DADOS" > "$TEMP"
    mv "$TEMP" "$ARQUIVO_BANCO_DE_DADOS"
    echo "Usuário removido com sucesso"
  else
    echo -e "${VERMELHO}ERRO: ${NO_COLOR}Usuário '$1' não encontrado na base de dados."
    exit 1
  fi
}

# ---------------- EXECUÇÃO ---------------- #

while [ -n "$1" ]
do
  case $1 in
    -i)
      [ -z "$2" -o -z "$3" ] && echo -e "${VERMELHO}ERRO: ${NO_COLOR}Você precisa digitar um nome de usuário e depois um email." && exit 1
      InserirUsuario $2 $3 &&  echo "Usuário '$2' inserido com sucesso."
      exit 0 ;;
    -r)
      [ -z "$2" ] && echo -e "${VERMELHO}ERRO: ${NO_COLOR}Você precisa digitar um nome de usuário para ser removido." && exit 1
      RemoverUsuario $2
      exit 0;;
  esac
  shift
done

ListarUsuarios
