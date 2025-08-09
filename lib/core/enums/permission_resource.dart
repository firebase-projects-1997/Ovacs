enum PermissionResource {
  case_('case'),
  client('client'),
  session('session'),
  document('document'),
  documentGroup('document_group'),
  message('message');

  const PermissionResource(this.value);
  final String value;

  static PermissionResource fromString(String resource) {
    switch (resource.toLowerCase()) {
      case 'case':
        return PermissionResource.case_;
      case 'client':
        return PermissionResource.client;
      case 'session':
        return PermissionResource.session;
      case 'document':
        return PermissionResource.document;
      case 'document_group':
        return PermissionResource.documentGroup;
      case 'message':
        return PermissionResource.message;
      default:
        throw ArgumentError('Unknown permission resource: $resource');
    }
  }

  String get displayName {
    switch (this) {
      case PermissionResource.case_:
        return 'Case';
      case PermissionResource.client:
        return 'Client';
      case PermissionResource.session:
        return 'Session';
      case PermissionResource.document:
        return 'Document';
      case PermissionResource.documentGroup:
        return 'Document Group';
      case PermissionResource.message:
        return 'Message';
    }
  }
}
