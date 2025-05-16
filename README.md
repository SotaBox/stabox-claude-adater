# Sotabox MCP Server

A Model Completion Protocol (MCP) server that connects Claude to Sotabox services.

## Overview

The Sotabox MCP Server implements the Model Completion Protocol to provide Claude with access to various Sotabox API tools. It handles the translation between Claude's function calls and the Sotabox, making it easy to extend Claude's capabilities with custom external tools.

## Features

- Support auto routing trieval multiple sotabox channels
- Answer with source citation if quested by prompt
- Integrate with claude pro "Extended Thining" for reasoning and extending retrieval if information not found.
- Compatile with sotabox API only

## Support OS:
 - MacOS 
 - Window
 - Linux

## Setup 
 - Download Sotabox Executor Adater in this folder (use correct os file)
 - Download sample config.json file
 - Config Sotabox APi key as the guide below
 - Download Claude Destop if you dont have one
 - Open the Claude setting --> Developer --> Edit Config
 - Replace the path of "Sotabox-mcp" and config.son into the config.


### Adding New Tools to Claudes

To add new tool to the Claude, please copy and past thi file to Claude config file:
```json
{
  "mcpServers": {
    "SotaboxMCP": {
      "command": "/Users/sotatek/Documents/Sandbox/SotaboxMCP/build/macos/sotabox-mcp",
      "args": [
        "-config",
        "/Users/sotatek/Documents/Sandbox/SotaboxMCP/config.json"
      ]
    }
  }
}
```

## Each tool has the following properties:
- **name**: The name of the tool (used to identify it in the MCP protocol)
- **description**: A description of what the tool does
- **apiKey**: The API key used for authentication with the Sotabox API
- **enabled**: Whether the tool is enabled or not

The default configuration includes only the "sotabox_guide" tool

```json
{
  "tools": [
    {
      "name": "sotabox_guide",
      "description": "the Sotabox Guide is the tool to query information about Sotabox product. Always answer based on the data provided with ciation clearly",
      "apiKey": "your sotabox api key",
      "enabled": true
    },
    {
      "name": "sotatek_hr",
      "description": "The Sotatek HR document is tool to retriev sotatek internal HR document. Always answer based on the data provided with ciation clearly",
      "apiKey": "your sotabox api key",
      "enabled": true
    },
    {
      "name": "Sotatek Porfolio",
      "description": "The Sotatek Portfolios document is tool to retriev sotatek internal HR document. Always answer based on the data provided with ciation clearly",
      "apiKey": "your sotabox api key",
      "enabled": true
    }
  ]
} 
```

To add a new tool, edit the configuration file and add a new entry to the `tools` array:

```json
{
  "tools": [
    {
      "name": "tool_name",
      "description": "Description of what the tool does...",
      "apiKey": "your-api-key",
      "enabled": true
    }
  ]
}
```

## Where to get sotabox-API key

- Sotabox - API key provided for Sotabox Channels' admin
- If you are staffs, please contact admin for have one
- In a sotabox channel --> control pannel --> chatbot --> cread new chatbot
- Select sources PDF/Wiki/Website, and fill required information
- Copy API key to the above config.son file each tools are one channels






