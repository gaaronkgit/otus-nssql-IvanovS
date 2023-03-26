/*Больше ограничений продумать не удалось :-)*/

ALTER TABLE orderitem
  ADD CONSTRAINT CK_Price_Greater_Than_Zero CHECK (price > 0);

ALTER TABLE orderitem
  ADD CONSTRAINT CK_Qu_Greater_Than_Zero CHECK (qu > 0);