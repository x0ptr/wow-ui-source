# WoW UI Source

This repo contains the latest WoW UI source code. Branches should reflect the most recent patches to their respective clients.

- [live -> ptr](https://github.com/Gethe/wow-ui-source/compare/live...ptr)
- [live -> ptr2](https://github.com/Gethe/wow-ui-source/compare/live...ptr2)
- [live -> beta](https://github.com/Gethe/wow-ui-source/compare/live...beta)

## Additional Resources

### Nameplate API Guide

This repository includes comprehensive documentation and examples for working with the nameplate API:

- **[Quick Reference Card](NAMEPLATE_QUICK_REFERENCE.md)** - Fast lookup for common nameplate operations
- **[Complete API Guide](NAMEPLATE_API_GUIDE.md)** - Comprehensive guide with examples for all methods
- **[Solution Overview](NAMEPLATE_SOLUTION.md)** - Overview of solutions to common nameplate problems
- **[Working Example Addon](Examples/NameplateExample/)** - Complete, ready-to-use addon demonstrating all concepts

These resources solve common issues like:
- Getting nameplate information from NPCs/enemies
- Proper use of `IsVisible()` (standard frame method)
- Obtaining `namePlateUnitToken` via events
- Filtering and tracking specific unit types
