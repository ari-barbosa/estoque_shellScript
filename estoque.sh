#!/bin/bash
#
# estoque.sh - Cadastro de produtos no estoque
#
# Autor:       Ariane Barbosa
# Manutenção:  Ariane Barbosa
#
# -------------------------------------------------------------------- #
# Essa aplicação serve para controle de estoque do cliente, com possibilidade de inserção, exclusão e
# listagem dos produtos.
#
# Exemplos:
#     $ ./nomeDoScript.sh -d 1
#     Neste exemplo o script será executado no modo debug nível 1.
# ------------------------------------------------------------------- #
# Histórico:
#
# # v1.0 08/10/2021, Ariane Barbosa:
#      - Primeira versão do estoque.
# ------------------------------------------------------------------ #
# Testado em:
#   GNU bash, version 3.2.57(1)-release (x86_64-apple-darwin20)
#   Copyright (C) 2007 Free Software Foundation, Inc.
# ------------------------------------------------------------------ #
# Agradecimentos:
#
# Professor Mateus Muller  - O projeto foi realizado com base no curso do professor, ministrado na
# plataforma UDEMY.
# ----------------------------------------------------------------- #


# --------------------- VARIÁVEIS --------------------------------- #
ARQUIVO_ESTOQUE="banco_estoque.txt"
SEP=:
TEMP=temp.$$
VERDE="\033[32;l"
VERMELHO="\033[31;l"
# ----------------------------------------------------------------- #


#  --------------------- TESTES  ---------------------------------- #
[ ! -e "$ARQUIVO_ESTOQUE" ] && echo "O Arquivo do banco de dados não existe!" && exit 1
[ ! -r "$ARQUIVO_ESTOQUE" ] && echo "O Arquivo não tem permissão de leitura!" && exit 1
[ ! -w "$ARQUIVO_ESTOQUE" ] && echo "O Arquivo não tem permissão de escrita!" && exit 1
[ ! -x "$(which dialog)" ] && sudo apt install dialog 1> /dev/null 2>&1
# ----------------------------------------------------------------- #


# ----------------------- FUNÇÕES --------------------------------- #
ListaEstoque () {
    egrep -v "ˆ#|ˆ$" "$ARQUIVO_ESTOQUE" | tr : ' ' > "$TEMP"
    dialog --title "Lista de Produtos" --textbox "$TEMP" 20 40
    rm -f "$TEMP"
}


ValidaExistenciaProduto () {
    grep -i -q "$1$SEP" "$ARQUIVO_ESTOQUE"
}


OrdenaLista () {
    sort "$ARQUIVO_ESTOQUE" > "$TEMP"
    mv "$TEMP" "$ARQUIVO_ESTOQUE"
}
# ----------------------------------------------------------------- #


# --------------------- EXECUÇÃO  --------------------------------- #
while :
do
    acao=$(dialog --title "Gerenciamento de Estoque" \
        --stdout \
        --menu "Escolha uma das opções abaixo:" \
        0 0 0 \
        listar "Listar todos os produtos do estoque" \
        remover "Remover um produto do estoque" \
    inserir "Inserir um novo usuário no sistema")
    [ $? -ne 0 ] && exit
    
    
    case $acao in
        listar) ListaEstoque ;;
        
        inserir)
            ultimo_id=$(egrep -v "ˆ#|ˆ$" "$ARQUIVO_ESTOQUE" | sort -h | tail -n 1 | cut -d $SEP -f 1)
            proximo_id=$(($ultimo_id+1))
            
            nome=$(dialog --title "Cadastro de produtos" --stdout --inputbox "Digite o nome do produto:" 0 0 )
            [ ! "$nome" ] && exit 1
            
            ValidaExistenciaProduto "$nome" && {
                dialog --title "AVISO" --msgbox "Produto já cadastrado no sistema!" 6 40
                exit 1
            }
            
            qtd=$(dialog --title "Cadastro de produtos" --stdout --inputbox "Digite a quantidade de produto:" 0 0 )
            [ $? -ne 0 ] && continue
            
            echo "$proximo_id$SEP$nome$SEP$qtd" >> "$ARQUIVO_ESTOQUE"
            dialog --title "AVISO" --msgbox "Produto cadastrado com sucesso!" 6 40
            
            ListaEstoque
        ;;
        
        
        remover)
            produtos=$(egrep "^#|^$" -v "$ARQUIVO_ESTOQUE" | sort -h | cut -d $SEP -f 1,2 | sed 's/:/ "/;s/$/"/')
            id_produto=$(eval dialog --stdout --menu \"Escolha um produto:\" 0 0 0 $produtos)
            [ $? -ne 0] && continue
            
            grep -i -v "^$id_produto$SEP" "$ARQUIVO_ESTOQUE" > "$TEMP"
            mv "$TEMP" "$ARQUIVO_ESTOQUE"
            
            dialog --msgbox "Usuário removido com sucesso!"
            ListaEstoque
        ;;
        
    esac
done
# ----------------------------------------------------------------- #
