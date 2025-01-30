import os
import argparse

def prepare_manifest(directory,num_chars,csv_file_name):
    """
    List all files in a given directory (non-recursive).

    Args:
        directory (str): The path to the directory.

    Returns:
        list: A list of file paths.
    """
    if not os.path.exists(directory):
        print(f"Error: The directory '{directory}' does not exist.")
        return []

    csv_file = open(csv_file_name,'w')

    # Records
    for f in os.listdir(directory):
        if os.path.isfile(os.path.join(directory, f)):
            sampleid = list(f)[:num_chars]
            direction = 'forward'
            if '2_paired' not in f:
                direction = 'reverse'
            csv_file.write(f'{sampleid},{os.path.join(directory, f)},{direction}\n')
    csv_file.close()

    return


def main():
    # Set up argument parser
    parser = argparse.ArgumentParser(description="Create a manifest file for qiime2 using a directory containing trimmomatic results.")
    parser.add_argument("--input", type=str,required=True, help="Path to input directory.")
    parser.add_argument("--output", type=str,required=True, help="Path to output directory.")
    parser.add_argument("--num_chars", type=int,required=True, help="Number of characters in filename representing sample id.")
    
    # Parse arguments
    args = parser.parse_args()

    # Filename 
    csv_file_name = os.path.join(args.output,'manifest.csv')

    if not os.path.exists(args.input):
        print(f"Error: The directory '{input}' does not exist.")
        return []

    csv_file = open(csv_file_name,'w')
    csv_file.write("sample-id,absolute-filepath,direction\n")

    # Iterate for each file and record its name along with direction and sampleid
    for f in os.listdir(args.input):
        if os.path.isfile(os.path.join(args.input, f)):
            # Logic to extract sample id
            sampleid = f.split("_")[0]

            # Find direction of read & write to file
            direction = ''
            if '2_paired' in f :
                csv_file.write(f'{sampleid},{os.path.join(args.input, f)},reverse\n')
            if '1_paired' in f:
                csv_file.write(f'{sampleid},{os.path.join(args.input, f)},forward\n')

    # Close file
    csv_file.close()

if __name__ == "__main__":
    main()