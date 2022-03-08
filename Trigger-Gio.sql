Create Table Tab_Exemplo (
 CodigoAutomatico      Integer
,Texto                 Varchar2(100)
,DataDaInclusao        Date
,UsuarioQueIncluiu     Varchar2(30)
,DataDaUltimaAlteracao Date
,UsuarioQueAlterou     Varchar2(30)
);
----------------------------------------------------------------------------------------------------
Create Table Tab_ExemploLogExclusao (
 CodigoAutomatico              Integer
,Texto                         Varchar2(100)
,DataDaInclusao                Date
,UsuarioQueIncluiu             Varchar2(30)
,DataDaUltimaAlteracao         Date
,UsuarioQueAlterou             Varchar2(30)
,DataDaExclusao                Date
,UsuarioDeRede                 Varchar2(30)
,UsuarioDoBanco                Varchar2(30)
,GerenciadorDeTarefasNome      Varchar2(64)
,GerenciadorDeTarefasDescricao Varchar2(64)
,DescricaoDaMaquina            Varchar2(64)
,EnderecoIP                    Varchar2(15)
);
----------------------------------------------------------------------------------------------------
Create Sequence Seq_Exemplo;
----------------------------------------------------------------------------------------------------
Create Or Replace Trigger TG_Tab_Exemplo -- Com o comando "Create Or Replace" não será necessário executar o comando "Drop Trigger" para depois executar o comando "Create Trigger"
  Before Insert Or Update Or Delete On Tab_Exemplo -- Com o comando "Insert Or Update" não será necessário criar 3 triggers separadas para "Insert/Update/Delete". Para saber qual ação está ocorrendo, utiliza-se as palavras reservadas "Inserting/Updating/Deleting" respectivamente para "Insert/Update/Delete"
  For Each Row -- Para cada linha modificada a trigger será disparada
Declare
  -- Declaração de variáveis utilizadas na trigger - Início
  vMensagemDeErro                Varchar2(32767);
  vNumeroDoErro                  Integer;
  vUsuarioDeRede                 V$session.OSUSER%Type;   -- %Type identifica dinamicamente o tipo de dado com base no parâmetro de origem (V$session.OSUSER   = Varchar2(30))
  vUsuarioDoBanco                V$session.USERNAME%Type; -- %Type identifica dinamicamente o tipo de dado com base no parâmetro de origem (V$session.USERNAME = Varchar2(30))
  vGerenciadorDeTarefasNome      V$session.PROGRAM%Type;  -- %Type identifica dinamicamente o tipo de dado com base no parâmetro de origem (V$session.PROGRAM  = Varchar2(64))
  vGerenciadorDeTarefasDescricao V$session.MODULE%Type;   -- %Type identifica dinamicamente o tipo de dado com base no parâmetro de origem (V$session.MODULE   = Varchar2(64))
  vDescricaoDaMaquina            V$session.MACHINE%Type;  -- %Type identifica dinamicamente o tipo de dado com base no parâmetro de origem (V$session.MACHINE  = Varchar2(64))
  vCodigoDaSessao                V$session.SID%Type;      -- %Type identifica dinamicamente o tipo de dado com base no parâmetro de origem (V$session.SID      = Number)
  vEnderecoIP                    Varchar2(15);
  -- Declaração de variáveis utilizadas na trigger - Fim
Begin -- Início da Trigger
  
  If (Inserting) Then -- Como a trigger é para "Insert Or Update Or Delete", utiliza-se respectivamente "Inserting/Updating/Deleting" para "Insert/Update/Delete"
    
    :New.CodigoAutomatico := Seq_Exemplo.Nextval; -- :New referencia todas as colunas da nova linha a ser inserida na tabela da trigger (Tab_Exemplo). Para identificar a coluna
    
    :New.UsuarioQueIncluiu := User;
    
    :New.DataDaInclusao := Sysdate;
    
    :New.DataDaUltimaAlteracao := Null;
    
    :New.UsuarioQueAlterou := Null;
    
  Elsif (Updating) Then -- Como a trigger é para "Insert Or Update Or Delete", utiliza-se respectivamente "Inserting/Updating/Deleting" para "Insert/Update/Delete"
  
    :New.DataDaUltimaAlteracao := Sysdate;
    
    :New.UsuarioQueAlterou := User;
    
  Else -- Só restou Deleting
  
    If (:Old.UsuarioQueIncluiu = User) Then
      
        vNumeroDoErro := -20010;
    
        vMensagemDeErro := Chr(13)
                        || Chr(13)
                        ||'Regra de negocio violada na trigger "Tab_Exemplo".' || Chr(13)
                        || Chr(13)
                        || 'O usuario "' || User || '" incluiu o registro.' || Chr(13)
                        || 'A exclusao deve ser executada utilizando outro usuario.' || Chr(13)
                        || Chr(13)
                        || Chr(13);
    
      Raise_Application_Error(vNumeroDoErro
                             ,vMensagemDeErro);
    
    Else
      
      Select
       sys_context ('USERENV', 'SID')
      Into
       vCodigoDaSessao
      From
       Dual;
      
      Select
       V$session.OSUSER                      As UsuarioDeRede
      ,V$session.USERNAME                    As DescricaoDoUsuarioDoBanco
      ,V$session.PROGRAM                     As GerenciadorDeTarefasNome
      ,V$session.MODULE                      As GerenciadorDeTarefasDescricao
      ,V$session.MACHINE                     As DescricaoDaMaquina
      ,sys_context ('USERENV', 'IP_ADDRESS') As EnderecoIP
      Into
       vUsuarioDeRede
      ,vUsuarioDoBanco
      ,vGerenciadorDeTarefasNome
      ,vGerenciadorDeTarefasDescricao
      ,vDescricaoDaMaquina
      ,vEnderecoIP
      From
       V$session
      Where 1 = 1
      And V$session.SID = vCodigoDaSessao;
    
      Insert Into Tab_ExemploLogExclusao (
       CodigoAutomatico
      ,Texto
      ,DataDaInclusao
      ,UsuarioQueIncluiu
      ,DataDaUltimaAlteracao
      ,UsuarioQueAlterou
      ,DataDaExclusao
      ,UsuarioDeRede
      ,UsuarioDoBanco
      ,GerenciadorDeTarefasNome
      ,GerenciadorDeTarefasDescricao
      ,DescricaoDaMaquina
      ,EnderecoIP
      ) Values (
       :Old.CodigoAutomatico          -- CodigoAutomatico
      ,:Old.Texto                     -- Texto
      ,:Old.DataDaInclusao            -- DataDaInclusao
      ,:Old.UsuarioQueIncluiu         -- UsuarioQueIncluiu
      ,:Old.DataDaUltimaAlteracao     -- DataDaUltimaAlteracao
      ,:Old.UsuarioQueAlterou         -- UsuarioQueAlterou
      ,Sysdate                        -- DataDaExclusao
      ,vUsuarioDeRede                 -- UsuarioDeRede
      ,vUsuarioDoBanco                -- UsuarioDoBanco
      ,vGerenciadorDeTarefasNome      -- GerenciadorDeTarefasNome
      ,vGerenciadorDeTarefasDescricao -- GerenciadorDeTarefasDescricao
      ,vDescricaoDaMaquina            -- DescricaoDaMaquina
      ,vEnderecoIP                    -- EnderecoIP
      );
    End If;
  
  End If;

End TG_Tab_Exemplo; -- Fim da Trigger
/
----------------------------------------------------------------------------------------------------
Insert Into Tab_Exemplo (
 CodigoAutomatico
,Texto
,DataDaInclusao
,UsuarioQueIncluiu
,DataDaUltimaAlteracao
,UsuarioQueAlterou
) Values (
 123456                                                  -- CodigoAutomatico      - será ignorado por causa da trigger (:New.CodigoAutomatico := Seq_Exemplo.Nextval;)
,'Primeira inclusao'                                     -- Texto                 - será armazenado
,To_Date('01/01/2022 01:23:45', 'DD/MM/RRRR HH24:MI:SS') -- DataDaInclusao        - será ignorado por causa da trigger (:New.DataDaInclusao := Sysdate;)
,'UsuarioQueIncluiu'                                     -- UsuarioQueIncluiu     - será ignorado por causa da trigger (:New.UsuarioQueIncluiu := User;)
,To_Date('31/12/2022 12:34:56', 'DD/MM/RRRR HH24:MI:SS') -- DataDaUltimaAlteracao - será ignorado por causa da trigger (:New.DataDaUltimaAlteracao := Null;)
,'UsuarioQueAlterou'                                     -- UsuarioQueAlterou     - será ignorado por causa da trigger (:New.UsuarioQueAlterou := Null;)
);
----------------------------------------------------------------------------------------------------
/*
Se os campos abaixo serão ignorados na inclusão:
- CodigoAutomatico
- DataDaInclusao
- UsuarioQueIncluiu
- DataDaUltimaAlteracao
- UsuarioQueAlterou
Pode-se incluir somente o campo restante:
- Texto
*/
----------------------------------------------------------------------------------------------------
Insert Into Tab_Exemplo (
 Texto
) Values (
 'Segunda inclusao' -- Texto - será armazenado
);
----------------------------------------------------------------------------------------------------
Select
 Tab_Exemplo.CodigoAutomatico
,Tab_Exemplo.Texto
,Tab_Exemplo.DataDaInclusao
,Tab_Exemplo.UsuarioQueIncluiu
,Tab_Exemplo.DataDaUltimaAlteracao
,Tab_Exemplo.UsuarioQueAlterou
From
 Tab_Exemplo
Where 1 = 1;
----------------------------------------------------------------------------------------------------
Update Tab_Exemplo Set
 Texto = Texto || ' - Primeira alteracao'
Where 1 = 1;
----------------------------------------------------------------------------------------------------
Select
 Tab_Exemplo.CodigoAutomatico
,Tab_Exemplo.Texto
,Tab_Exemplo.DataDaInclusao
,Tab_Exemplo.UsuarioQueIncluiu
,Tab_Exemplo.DataDaUltimaAlteracao
,Tab_Exemplo.UsuarioQueAlterou
From
 Tab_Exemplo
Where 1 = 1;
----------------------------------------------------------------------------------------------------
Update Tab_Exemplo Set
 Texto = Texto || ' - Segunda alteracao'
Where 1 = 1;
----------------------------------------------------------------------------------------------------
Select
 Tab_Exemplo.CodigoAutomatico
,Tab_Exemplo.Texto
,Tab_Exemplo.DataDaInclusao
,Tab_Exemplo.UsuarioQueIncluiu
,Tab_Exemplo.DataDaUltimaAlteracao
,Tab_Exemplo.UsuarioQueAlterou
From
 Tab_Exemplo
Where 1 = 1;
----------------------------------------------------------------------------------------------------
Delete From Tab_Exemplo;
----------------------------------------------------------------------------------------------------
Create Or Replace Trigger TG_Tab_Exemplo -- Com o comando "Create Or Replace" não será necessário executar o comando "Drop Trigger" para depois executar o comando "Create Trigger"
  Before Insert Or Update Or Delete On Tab_Exemplo -- Com o comando "Insert Or Update" não será necessário criar 3 triggers separadas para "Insert/Update/Delete". Para saber qual ação está ocorrendo, utiliza-se as palavras reservadas "Inserting/Updating/Deleting" respectivamente para "Insert/Update/Delete"
  For Each Row -- Para cada linha modificada a trigger será disparada
Declare
  -- Declaração de variáveis utilizadas na trigger - Início
  vMensagemDeErro                Varchar2(32767);
  vNumeroDoErro                  Integer;
  vUsuarioDeRede                 V$session.OSUSER%Type;   -- %Type identifica dinamicamente o tipo de dado com base no parâmetro de origem (V$session.OSUSER   = Varchar2(30))
  vUsuarioDoBanco                V$session.USERNAME%Type; -- %Type identifica dinamicamente o tipo de dado com base no parâmetro de origem (V$session.USERNAME = Varchar2(30))
  vGerenciadorDeTarefasNome      V$session.PROGRAM%Type;  -- %Type identifica dinamicamente o tipo de dado com base no parâmetro de origem (V$session.PROGRAM  = Varchar2(64))
  vGerenciadorDeTarefasDescricao V$session.MODULE%Type;   -- %Type identifica dinamicamente o tipo de dado com base no parâmetro de origem (V$session.MODULE   = Varchar2(64))
  vDescricaoDaMaquina            V$session.MACHINE%Type;  -- %Type identifica dinamicamente o tipo de dado com base no parâmetro de origem (V$session.MACHINE  = Varchar2(64))
  vCodigoDaSessao                V$session.SID%Type;      -- %Type identifica dinamicamente o tipo de dado com base no parâmetro de origem (V$session.SID      = Number)
  vEnderecoIP                    Varchar2(15);
  -- Declaração de variáveis utilizadas na trigger - Fim
Begin -- Início da Trigger
  
  If (Inserting) Then -- Como a trigger é para "Insert Or Update Or Delete", utiliza-se respectivamente "Inserting/Updating/Deleting" para "Insert/Update/Delete"
    
    :New.CodigoAutomatico := Seq_Exemplo.Nextval; -- :New referencia todas as colunas da nova linha a ser inserida na tabela da trigger (Tab_Exemplo). Para identificar a coluna
    
    :New.UsuarioQueIncluiu := User;
    
    :New.DataDaInclusao := Sysdate;
    
    :New.DataDaUltimaAlteracao := Null;
    
    :New.UsuarioQueAlterou := Null;
    
  Elsif (Updating) Then -- Como a trigger é para "Insert Or Update Or Delete", utiliza-se respectivamente "Inserting/Updating/Deleting" para "Insert/Update/Delete"
  
    :New.DataDaUltimaAlteracao := Sysdate;
    
    :New.UsuarioQueAlterou := User;
    
  Else -- Só restou Deleting
  
    /*
    If (:Old.UsuarioQueIncluiu = User) Then
      
        vNumeroDoErro := -20010;
    
        vMensagemDeErro := Chr(13)
                        || Chr(13)
                        ||'Regra de negocio violada na trigger "Tab_Exemplo".' || Chr(13)
                        || Chr(13)
                        || 'O usuario "' || User || '" incluiu o registro.' || Chr(13)
                        || 'A exclusao deve ser executada utilizando outro usuario.' || Chr(13)
                        || Chr(13)
                        || Chr(13);
    
      Raise_Application_Error(vNumeroDoErro
                             ,vMensagemDeErro);
    
    Else
      */
      
      Select
       sys_context ('USERENV', 'SID')
      Into
       vCodigoDaSessao
      From
       Dual;
      
      Select
       V$session.OSUSER                      As UsuarioDeRede
      ,V$session.USERNAME                    As DescricaoDoUsuarioDoBanco
      ,V$session.PROGRAM                     As GerenciadorDeTarefasNome
      ,V$session.MODULE                      As GerenciadorDeTarefasDescricao
      ,V$session.MACHINE                     As DescricaoDaMaquina
      ,sys_context ('USERENV', 'IP_ADDRESS') As EnderecoIP
      Into
       vUsuarioDeRede
      ,vUsuarioDoBanco
      ,vGerenciadorDeTarefasNome
      ,vGerenciadorDeTarefasDescricao
      ,vDescricaoDaMaquina
      ,vEnderecoIP
      From
       V$session
      Where 1 = 1
      And V$session.SID = vCodigoDaSessao;
    
      Insert Into Tab_ExemploLogExclusao (
       CodigoAutomatico
      ,Texto
      ,DataDaInclusao
      ,UsuarioQueIncluiu
      ,DataDaUltimaAlteracao
      ,UsuarioQueAlterou
      ,DataDaExclusao
      ,UsuarioDeRede
      ,UsuarioDoBanco
      ,GerenciadorDeTarefasNome
      ,GerenciadorDeTarefasDescricao
      ,DescricaoDaMaquina
      ,EnderecoIP
      ) Values (
       :Old.CodigoAutomatico          -- CodigoAutomatico
      ,:Old.Texto                     -- Texto
      ,:Old.DataDaInclusao            -- DataDaInclusao
      ,:Old.UsuarioQueIncluiu         -- UsuarioQueIncluiu
      ,:Old.DataDaUltimaAlteracao     -- DataDaUltimaAlteracao
      ,:Old.UsuarioQueAlterou         -- UsuarioQueAlterou
      ,Sysdate                        -- DataDaExclusao
      ,vUsuarioDeRede                 -- UsuarioDeRede
      ,vUsuarioDoBanco                -- UsuarioDoBanco
      ,vGerenciadorDeTarefasNome      -- GerenciadorDeTarefasNome
      ,vGerenciadorDeTarefasDescricao -- GerenciadorDeTarefasDescricao
      ,vDescricaoDaMaquina            -- DescricaoDaMaquina
      ,vEnderecoIP                    -- EnderecoIP
      );
    End If;
  
  -- End If;

End TG_Tab_Exemplo; -- Fim da Trigger
/
----------------------------------------------------------------------------------------------------
Delete From Tab_Exemplo;
----------------------------------------------------------------------------------------------------
Select
 Tab_Exemplo.CodigoAutomatico
,Tab_Exemplo.Texto
,Tab_Exemplo.DataDaInclusao
,Tab_Exemplo.UsuarioQueIncluiu
,Tab_Exemplo.DataDaUltimaAlteracao
,Tab_Exemplo.UsuarioQueAlterou
From
 Tab_Exemplo
Where 1 = 1;
----------------------------------------------------------------------------------------------------
Select
 Tab_ExemploLogExclusao.CodigoAutomatico
,Tab_ExemploLogExclusao.Texto
,Tab_ExemploLogExclusao.DataDaInclusao
,Tab_ExemploLogExclusao.UsuarioQueIncluiu
,Tab_ExemploLogExclusao.DataDaUltimaAlteracao
,Tab_ExemploLogExclusao.UsuarioQueAlterou
,Tab_ExemploLogExclusao.DataDaExclusao
,Tab_ExemploLogExclusao.UsuarioDeRede
,Tab_ExemploLogExclusao.UsuarioDoBanco
,Tab_ExemploLogExclusao.GerenciadorDeTarefasNome
,Tab_ExemploLogExclusao.GerenciadorDeTarefasDescricao
,Tab_ExemploLogExclusao.DescricaoDaMaquina
,Tab_ExemploLogExclusao.EnderecoIP
From
 Tab_ExemploLogExclusao
Where 1 = 1;
----------------------------------------------------------------------------------------------------
Drop Sequence Seq_Exemplo;
----------------------------------------------------------------------------------------------------
Drop Table Tab_Exemplo;
----------------------------------------------------------------------------------------------------
Drop Table Tab_ExemploLogExclusao;
