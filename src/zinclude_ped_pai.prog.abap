*&---------------------------------------------------------------------*
*& Include          ZINCLUDE_PED_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE sy-ucomm.
    WHEN 'SAVE'.
      PERFORM f_alv_check_input.
    WHEN 'BACK' OR 'LEAVE' OR 'EXIT' OR 'CANC'.
      LEAVE PROGRAM.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.
