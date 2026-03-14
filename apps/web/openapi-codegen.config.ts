import { defineConfig } from '@openapi-codegen/cli';
import {
  generateFetchers,
  generateReactQueryComponents,
  generateSchemaTypes
} from '@openapi-codegen/typescript';

export default defineConfig({
  apiTypes: {
    from: {
      source: 'file',
      relativePath: '../../generated/openapi.json',
    },
    outputDir: 'src/generated/api',
    to: async (context) => {
      const filenamePrefix = "api";
      const { schemasFiles } = await generateSchemaTypes(context, {
        filenamePrefix,
      });

      await generateReactQueryComponents(context, {
        schemasFiles,
        filenamePrefix,
        filenameCase: 'kebab',
      });
    },
  },
});
