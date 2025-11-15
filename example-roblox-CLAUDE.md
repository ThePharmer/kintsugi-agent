# Roblox Game - Claude Code Instructions

## Project Context
This is a Roblox simulation game built with Luau. Key systems:
- Player DataStore persistence
- Shop/inventory system
- Quest system
- Admin commands

## Code Standards

### Security Rules
- **NEVER** trust client input - validate everything on server
- **NEVER** give clients access to RemoteFunctions that modify data directly
- **ALWAYS** use RemoteEvents for client→server communication
- **ALWAYS** sanity-check player data before saving to DataStore

### Roblox Patterns
- Server scripts in `ServerScriptService`
- Client scripts in `StarterPlayer/StarterPlayerScripts`
- Shared modules in `ReplicatedStorage/Modules`
- RemoteEvents in `ReplicatedStorage/Remotes`

### Code Style
- Use PascalCase for class-like modules
- Use camelCase for functions and variables
- Add type annotations: `local function damage(player: Player, amount: number): boolean`
- Comment complex game logic

## Available Commands
- `/create-tool [name]` - Generate a tool with animations
- `/create-gui [name]` - Create UI screen with proper structure
- `/create-datastore` - Set up player data persistence
- `/create-npc [type]` - Spawn NPC with basic AI

## Testing
- Use Roblox Studio's test servers (2+ players) for network testing
- Test with published game for DataStore validation
- Check server/client console for errors

## Important Reminders
- This game runs on Roblox servers - be mindful of performance
- DataStores have rate limits - batch saves when possible
- Mobile players may have different screen sizes - UI must be responsive
