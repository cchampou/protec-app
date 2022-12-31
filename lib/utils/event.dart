

String toReadableAvailability(String availability) {
  switch (availability) {
    case 'accepted':
      return 'disponible';
    case 'refused':
      return 'non-disponible';
    default:
      return 'Inconnu';
  }
}
