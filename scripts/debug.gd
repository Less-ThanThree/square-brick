extends Node

const ISDEBUG = true

func print_debug_matrix(matrix: Array, descript: String = "Debug matrix"):
	print(descript)
	for row in matrix:
		print(row)
