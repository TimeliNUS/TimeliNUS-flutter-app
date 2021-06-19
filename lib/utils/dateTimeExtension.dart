extension Date on DateTime {
  DateTime stripTime() {
    return new DateTime(this.year, this.month, this.day);
  }
}
