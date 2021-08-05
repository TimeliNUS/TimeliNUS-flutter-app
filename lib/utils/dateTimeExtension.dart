extension Date on DateTime {
  DateTime stripTime() {
    return new DateTime(this.year, this.month, this.day);
  }

  String printTime() {
    return this.hour.toString().padLeft(2, '0') + ":" + this.minute.toString().padLeft(2, '0');
  }
}
