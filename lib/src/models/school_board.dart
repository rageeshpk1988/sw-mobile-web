class SchoolBoard {
  final int boardId;
  final String board;

  SchoolBoard({
    required this.boardId,
    required this.board,
  });

  factory SchoolBoard.fromJson(Map<String, dynamic> json) {
    return SchoolBoard(
      boardId: json['boardId'],
      board: json['board'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'boardId': boardId,
      'board': board,
    };
  }

  @override
  String toString() => board;

  //this method will prevent the override of toString
  bool filterByName(String filter) {
    return this.board.toLowerCase().contains(filter.toLowerCase());
  }
}
