# 오토로드 등록 스크립트
extends Node

"""
게임 실행 시 외부 데이터(CSV)를 읽어와
Dictionary 구조로 가공(Parsing)한 뒤,
DataManager에 전달하는 역할을 하는 스크립트
"""

##################################################
# 읽어올 데이터 파일의 경로를 상수로 지정
const DROP_TABLE_FILE_PATH: String = "res://data/drop_table.CSV"

##################################################
# 노드가 준비 완료되었을 때 자동으로 실행되는 함수
func _ready() -> void:
	_load_csv_file()

##################################################
# CSV 파일을 열고 한 줄씩 읽어 Dictionary로 가공하는 함수
func _load_csv_file() -> void:
	# 지정한 경로에 파일이 존재하는지 검사
	if not FileAccess.file_exists(DROP_TABLE_FILE_PATH):
		push_error("File Path Error")
		return	# 파일이 없으면 더 이상 진행하지 않고 함수를 종료
	
	# 파일을 '읽기(READ) 모드'로 안전하게 엶
	var file: FileAccess = \
			FileAccess.open(DROP_TABLE_FILE_PATH, FileAccess.READ)
	if not file:
		push_error("File Open Error")
		return	# 어떤 이유로든 파일이 안 열리면 즉시 종료
	
	# CSV 파일의 첫 번째 행(제목행)을 읽어와 '인덱스 지도'를 생성할 변수
	var header_map: Dictionary = {}
	if not file.eof_reached():	# 파일의 끝(End of File)에 도달하지 않았다면
		# CSV의 첫 줄을 통째로 긁어와 쉼표(,) 기준으로 쪼갠 뒤 담음
		var header: PackedStringArray = file.get_csv_line()
		# 쪼개진 header의 크기만큼 반복을 하면서 번호(i)를 하나씩 확인
		for i in range(header.size()):
			# strip_edges()를 사용하여 혹시 모를 양 끝의 공백을 깔끔하게 제거
			var column_name: String = header[i].strip_edges()
			# Key에 현재 방 번호인 인덱스 숫자(i)를 매칭하여 기록
			header_map[column_name] = i
	
	# 한 줄씩 데이터를 읽어와 임시로 저장할 빈 테이블 공간을 만듦
	var temporary_table: Dictionary = {}
	while not file.eof_reached():	# 파일의 끝(End of File)에 도달하지 않았다면
		# 현재 읽고 있는 행의 데이터를 쉼표(,) 기준으로 쪼개어 line 변수에 담음
		var line: PackedStringArray = file.get_csv_line()
		
		# 데이터의 줄이 깨졌거나 데이터가 비어있는 오류 방지를 위함
		if line.size() < header_map.size():
			continue
		
		# 기획 수정이나 디버깅을 위해 주석으로 남겨둔 열 목록
		#var number: String = line[header_map["number"]]
		#var percentage: String = line[header_map["percentage"]]
		
		# 헤더를 사용해 각 Key가 몇 번째 칸에 있었는지 찾아내고, 그 칸의 문자열을 가져옴
		# strip_edges()를 사용하여 혹시 모를 양 끝의 공백을 깔끔하게 제거
		var item_code: String = line[header_map["item_code"]].strip_edges()
		var item_name: String = line[header_map["item_name"]].strip_edges()
		var raw_weight: String = line[header_map["raw_weight"]].strip_edges()
		
		# 데이터 누락의 오류 방지를 위함
		if item_code == "" or item_name == "":
			continue
		
		# CSV에서 긁어온 가중치는 숫자 모양을 한 문자열 상태
		# 수학적 연산을 해야 하므로, 정수형(int)으로 변환
		var weight_int: int = raw_weight.to_int()
		
		# item_code를 고유 Key로 삼아, 그 안에 데이터를 구조화
		temporary_table[item_code] = {
			"item_name": item_name,
			"raw_weight": weight_int
		}
	
	# DataManager의 데이터 설정
	DataManager.set_drop_table_data(temporary_table)
