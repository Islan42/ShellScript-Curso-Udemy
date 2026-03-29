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
  grep -E -v "^#|^$" $ARQUIVO_BANCO_DE_DADOS > $TEMP
  dialog --textbox $TEMP 20 40 --title "Lista de Usuários"
  rm -f $TEMP
}

ValidarExistenciaUsuario () {
  grep -i -q "$1$SEP" "$ARQUIVO_BANCO_DE_DADOS"
}

InserirUsuario () {
  local nome=""
  while [ -z $nome ]
  do
    nome="$(dialog --inputbox 'Digite o seu nome' 0 0 --stdout)"
    [ $? -ne 0 ] && return
  done

  if ValidarExistenciaUsuario "$nome"
  then
    dialog --title "ERRO FATAL"  --msgbox "Usuário '$nome' já existe na base de dados." 0 0
  else
    ultimo_indice=$(grep -E -v "^#|^$" "$ARQUIVO_BANCO_DE_DADOS" | sort -n | tail -n 1 | cut -d "$SEP" -f 1)
    novo_indice=$(($ultimo_indice + 1))
    local email=""
    while [ -z $email ]
    do
      email="$(dialog --inputbox 'Digite o email' 0 0 --stdout)"
      [ $? -ne 0 ] && return
    done
    echo "$novo_indice$SEP$nome$SEP$email" >> "$ARQUIVO_BANCO_DE_DADOS"
    dialog --title "SUCESSO" --msgbox "Usuário cadastrado com sucesso." 0 0
  fi
}

RemoverUsuario () {
  local nome=""
  while [ -z $nome ]
  do
    nome="$(dialog --title 'Remover usuário' --stdout --inputbox 'Nome do usuário p/ remover' 0 0)"
    [ $? -ne 0 ] && return
  done

  if ValidarExistenciaUsuario "$nome"
  then
    grep -v -i "$nome$SEP" "$ARQUIVO_BANCO_DE_DADOS" > "$TEMP"
    mv "$TEMP" "$ARQUIVO_BANCO_DE_DADOS"
    dialog --title "SUCESSO" --msgbox "Usuário removido com sucesso." 0 0
  else
    dialog --title "ERRO" --msgbox "Usuário $nome não encontrado na base de dados." 0 0
  fi
}

# ---------------- EXECUÇÃO ---------------- #

#while [ -n "$1" ]
#do
#  case $1 in
#    -i)
#      [ -z "$2" -o -z "$3" ] && echo -e "${VERMELHO}ERRO: ${NO_COLOR}Você precisa digitar um nome de usuário e depois um email." && exit 1
#      InserirUsuario $2 $3 &&  echo "Usuário '$2' inserido com sucesso."
#      exit 0 ;;
#    -r)
#      [ -z "$2" ] && echo -e "${VERMELHO}ERRO: ${NO_COLOR}Você precisa digitar um nome de usuário para ser removido." && exit 1
#      RemoverUsuario $2
#      exit 0;;
#  esac
#  shift
#done

#ListarUsuarios
#InserirUsuario

acao=""
while [ "$acao" != "sair" ]
do
 acao=$( dialog  --title "Sistema de Cadastro de Usuários" --stdout --menu "Escolha uma das opções abaixo" \
         0 0 0 \
         listar "Lista todos os usuários" \
         inserir "Insere um novo usuário" \
         remover "Remove um usuário" \
         sair "Fecha o programa"\
       )
 [ $? -ne 0 ] && acao="sair"

 case $acao in
  listar)
    ListarUsuarios ;;
  inserir)
    InserirUsuario ;;
  remover)
    RemoverUsuario ;;
 esac
done
