extends Node

signal updateCoins
var coins : int
func notify_coin_update(new_coin : int):
	if new_coin > 0 and new_coin < 9:
		$Coin.play()
	coins += new_coin
	updateCoins.emit()
	
