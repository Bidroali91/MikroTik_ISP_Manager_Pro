# MikroTik ISP Manager Pro — API Documentation

## RouterOS API Protocol

The system communicates with MikroTik routers using the native RouterOS API binary protocol on port 8728.

### Connection
```dart
final client = RouterOSClient();
await client.connect('192.168.88.1', port: 8728);
await client.login('admin', 'password');
```

### Services

#### HotspotApi
| Method | Description |
|--------|-------------|
| `getProfiles()` | List hotspot profiles |
| `listUsers()` | List all users |
| `addUser(name, pass, profile)` | Create user |
| `updateUser(id, fields)` | Edit user |
| `removeUser(id)` | Delete user |
| `enableUser(id)` | Enable user |
| `disableUser(id)` | Disable user |
| `getActiveUsers()` | List online users |
| `clearActiveSessions()` | Remove all sessions |
| `getActiveUserCount()` | Count active users |

#### PppoeApi
| Method | Description |
|--------|-------------|
| `listUsers()` | List PPPoE secrets |
| `addUser(name, pass, service, profile)` | Create subscriber |
| `updateUser(id, fields)` | Update subscriber |
| `removeUser(id)` | Delete subscriber |
| `enableUser(id)` | Enable account |
| `disableUser(id)` | Disable account |
| `getActiveSessions()` | List active PPPoE sessions |
| `disconnectSession(id)` | Force disconnect |

#### SystemApi
| Method | Description |
|--------|-------------|
| `getResource()` | System resources |
| `getHealth()` | System health (temp, voltage) |
| `getIdentity()` | Router identity |
| `createBackup(name)` | System backup |
| `listFiles(type)` | List router files |
| `reboot()` | Reboot router |
| `getInterfaces()` | List interfaces |
| `setInterfaceEnabled(id, enable)` | Toggle interface |

### Firebase Services

#### Authentication
- `signInWithEmailAndPassword(email, password)`
- `createUserWithEmailAndPassword(email, password)`
- `signOut()`
- `sendPasswordResetEmail(email)`

#### Firestore Collections
- `users/{uid}`
- `routers/{routerId}`
- `hotspot_users/{docId}`
- `pppoe_users/{docId}`
- `sales/{saleId}`
- `backups/{backupId}`
- `notifications/{notifId}`
- `complaints/{complaintId}`
- `tickets/{ticketId}`
- `electricity/{docId}`
- `maintenance/{docId}`
- `settings/{docId}`
- `logs/{logId}`
