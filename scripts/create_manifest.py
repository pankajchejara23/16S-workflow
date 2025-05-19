import os
import argparse
import re

# Predefined lambda functions
LAMBDA_MAPPINGS = {
    "first_dash": lambda x: x.split("-")[0],
    "first_underscore": lambda x: x.split("_")[0],
    "identity":lambda x:x
}

def prepare_manifest(input, output, sampleid_extractor, 
                     csv_file_name, 
                     forward_id,
                     reverse_id):
    """
    List all files in a given directory (non-recursive).

    Args:
        directory (str): The path to the directory.
        sample_extractor (Callable): Function to extract sample id
        csv_file_name (str): Name of manifest file
        forward_id (str): string which will be used to determine forward read(e.g., '1_paired')
        reverse_id (str): string which will be used to determine reverse read(e.g., '2_paired')

    Returns:
        list: A list of file paths.
    """
     # Filename 
    csv_file_name = os.path.join(output,'manifest.csv')

    if not os.path.exists(input):
        print(f"Error: The directory '{input}' does not exist.")
        return []

    csv_file = open(csv_file_name,'w')
    csv_file.write("sample-id,absolute-filepath,direction\n")

    # Iterate for each file and record its name along with direction and sampleid
    for f in os.listdir(input):
        if os.path.isfile(os.path.join(input, f)):
            # Logic to extract sample id
            sampleid = sampleid_extractor(f)
            print(f,' ',sampleid)
            # Find direction of read & write to file
            direction = ''
            if reverse_id in f :
                csv_file.write(f'{sampleid},{os.path.abspath(os.path.join(input, f))},reverse\n')
            if forward_id in f:
                csv_file.write(f'{sampleid},{os.path.abspath(os.path.join(input, f))},forward\n')

    print(f'Manifest file:{csv_file_name} is generated')

    # Close file
    csv_file.close()

    return


def main():
    # Set up argument parser
    parser = argparse.ArgumentParser(description="Create a manifest file for qiime2.")
    parser.add_argument("--input", type=str,required=True, help="Path to input directory.")
    parser.add_argument("--output", type=str,required=True, help="Path to output directory.")
    parser.add_argument(
        "--extract",
        choices=LAMBDA_MAPPINGS.keys(),
        default="first_dash",
        help="Sample ID extraction method"
    )
    parser.add_argument("--filename", type=str,default="manifest.csv", help="Name of manifest file")

    parser.add_argument("--forward_read_pat", type=str,default="_R1_", help="Substring present in forward read")
    parser.add_argument("--reverse_read_pat", type=str,default="_R2_", help="Substring present in reverse read")
    
    # Parse arguments
    args = parser.parse_args()

    # To extract sampleid from filename
    extractor = LAMBDA_MAPPINGS[args.extract]

    # Prepare manifest file
    prepare_manifest(args.input, args.output, extractor, args.filename, args.forward_read_pat,args.reverse_read_pat)


if __name__ == "__main__":
    main()