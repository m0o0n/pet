import * as fs from 'node:fs';

const fetcherPath = 'src/generated/api/api-fetcher.ts';
const customFetcherPath = 'src/utils/custom-fetcher.ts';

const customizeFetcher = () => {
  try {
    const content = fs.readFileSync(customFetcherPath, 'utf-8');
    fs.writeFileSync(fetcherPath, content, 'utf-8');
    console.log('✓ api-fetcher.ts replaced with custom axios fetcher');
  } catch (error) {
    console.error('Error customizing fetcher:', error);
  }
};

customizeFetcher();
