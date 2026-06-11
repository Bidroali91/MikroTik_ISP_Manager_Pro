# MikroTik ISP Manager Pro — Firebase Database Schema

## Collections

### users
| Field | Type | Description |
|-------|------|-------------|
| `email` | String | User email address |
| `fullName` | String | Full display name |
| `role` | String | `super_admin`, `admin`, `operator`, `sales_agent`, `viewer` |
| `isActive` | Boolean | Account active status |
| `phone` | String? | Phone number |
| `photoUrl` | String? | Profile photo URL |
| `createdAt` | Timestamp | Account creation date |
| `lastLogin` | Timestamp | Last login timestamp |
| `routerIds` | Array<String> | Associated router IDs |

### routers
| Field | Type | Description |
|-------|------|-------------|
| `name` | String | Router display name |
| `host` | String | IP address |
| `port` | Number | API port (default: 8728) |
| `username` | String | RouterOS username |
| `password` | String | RouterOS password |
| `useTls` | Boolean | Use TLS connection |
| `isConnected` | Boolean | Connection status |
| `identity` | String? | Router identity |
| `version` | String? | RouterOS version |
| `model` | String? | Router model |
| `uptime` | String? | System uptime |
| `cpuLoad` | Number? | CPU usage percentage |
| `temperature` | Number? | System temperature |
| `createdAt` | Timestamp | Added date |
| `ownerId` | String | User ID who owns this router |

### hotspot_users
| Field | Type | Description |
|-------|------|-------------|
| `routerId` | String | Associated router ID |
| `name` | String | Username |
| `password` | String | Password |
| `profile` | String | Hotspot profile |
| `comment` | String? | Additional notes |
| `disabled` | Boolean | Account disabled |
| `uptime` | String? | Session uptime |
| `bytesIn` | Number | Bytes downloaded |
| `bytesOut` | Number | Bytes uploaded |
| `limitUptime` | String? | Session time limit |
| `expiresAt` | Timestamp? | Account expiry |
| `createdAt` | Timestamp | Creation date |
| `price` | Number? | Sale price |

### pppoe_users
| Field | Type | Description |
|-------|------|-------------|
| `routerId` | String | Associated router |
| `username` | String | PPPoE username |
| `password` | String | PPPoE password |
| `service` | String | Service type |
| `profile` | String | Bandwidth profile |
| `disabled` | Boolean | Account disabled |
| `remoteAddress` | String? | Assigned IP |
| `uptime` | String? | Session uptime |
| `bytesIn` | Number | Bytes downloaded |
| `bytesOut` | Number | Bytes uploaded |
| `comment` | String? | Notes |
| `expiresAt` | Timestamp? | Expiry date |
| `price` | Number? | Price |

### sales
| Field | Type | Description |
|-------|------|-------------|
| `userId` | String | Selling user |
| `routerId` | String | Associated router |
| `type` | String | `voucher`, `recharge`, `pppoe` |
| `profile` | String? | Service profile |
| `quantity` | Number | Quantity sold |
| `unitPrice` | Number | Price per unit |
| `totalAmount` | Number | Total sale amount |
| `customerName` | String? | Customer name |
| `customerPhone` | String? | Customer phone |
| `notes` | String? | Sale notes |
| `createdAt` | Timestamp | Sale timestamp |

### backups
| Field | Type | Description |
|-------|------|-------------|
| `routerId` | String | Source router |
| `fileName` | String | Backup filename |
| `fileSize` | Number | File size in bytes |
| `status` | String | `pending`, `completed`, `failed` |
| `storageUrl` | String? | Cloud storage URL |
| `createdAt` | Timestamp | Backup date |
| `createdBy` | String? | User who created |

### notifications
| Field | Type | Description |
|-------|------|-------------|
| `userId` | String | Target user |
| `title` | String | Notification title |
| `body` | String | Notification body |
| `type` | String | `info`, `warning`, `error`, `success` |
| `isRead` | Boolean | Read status |
| `routerId` | String? | Related router |
| `data` | Map? | Additional payload |
| `createdAt` | Timestamp | Creation time |

### complaints
| Field | Type | Description |
|-------|------|-------------|
| `userId` | String | Customer user ID |
| `title` | String | Complaint title |
| `description` | String | Complaint details |
| `status` | String | `open`, `in_progress`, `resolved`, `closed` |
| `priority` | String | `low`, `medium`, `high`, `critical` |
| `assignedTo` | String? | Assigned staff |
| `createdAt` | Timestamp | Submission date |
| `resolvedAt` | Timestamp? | Resolution date |
| `resolution` | String? | Resolution notes |

### electricity
| Field | Type | Description |
|-------|------|-------------|
| `routerId` | String | Related router |
| `powerOn` | Boolean | Main power status |
| `generatorOn` | Boolean | Generator status |
| `voltage` | Number? | Current voltage |
| `status` | String? | Status description |
| `timestamp` | Timestamp | Reading time |

### maintenance
| Field | Type | Description |
|-------|------|-------------|
| `routerId` | String | Related router |
| `type` | String | `scheduled`, `emergency`, `preventive` |
| `title` | String | Maintenance title |
| `description` | String | Details |
| `status` | String | `scheduled`, `in_progress`, `completed`, `cancelled` |
| `performedBy` | String? | Technician |
| `createdAt` | Timestamp | Created date |
| `completedAt` | Timestamp? | Completion date |
| `notes` | String? | Additional notes |

## Security Rules
- Users can only access their own data
- Router access restricted to owner
- Sales read restricted to own, create allowed for authenticated
- All other collections require authentication
